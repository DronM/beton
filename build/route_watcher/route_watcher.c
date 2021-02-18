#include <libwebsockets.h>
#include <string.h>
#include <signal.h>
#include "json.h"

#define MT_EVENT_NOTIFY		0
#define MT_ERROR		1
#define MT_REGISTERED		2

#define REG_ID_MAX		50
#define RESP_BUFFER_SIZE	1024

static struct my_conn {
	lws_sorted_usec_list_t	sul;	     /* schedule connection retry */
	struct lws		*wsi;	     /* related wsi if any */
	uint16_t		retry_count; /* count of consequetive retries */
} mco;

static struct lws_context *context;
static int interrupted, port = 1337, ssl_connection = LCCSCF_USE_SSL;
static const char *server_address = "localhost",
		  *pro = "beton-protocol";

char *client_id;

// NOTICE: data which is sent always needs to have a certain amount of memory (LWS_PRE) preserved for headers
unsigned char resp_buf[LWS_PRE + RESP_BUFFER_SIZE];

/*
 * The retry and backoff policy we want to use for our client connections
 */

static const uint32_t backoff_ms[] = { 1000, 2000, 3000, 4000, 5000 };

static const lws_retry_bo_t retry = {
	.retry_ms_table			= backoff_ms,
	.retry_ms_table_count		= LWS_ARRAY_SIZE(backoff_ms),
	.conceal_count			= LWS_ARRAY_SIZE(backoff_ms),

	.secs_since_valid_ping		= 3,  /* force PINGs after secs idle */
	.secs_since_valid_hangup	= 10, /* hangup after secs idle */

	.jitter_percent			= 20,
};

//register command
void cmd_register(struct lws *wsi){
	
	const char *token = "some_token";
	const unsigned int token_expires = 123456789;
	int msg_n = sprintf (resp_buf+LWS_PRE, "{\"cmd\":\"registerListener\",\"appId\":\"beton\",\"token\":\"%s\",\"tokenExpires\":\"%d\"}", token,token_expires);		
	lws_write(wsi, &resp_buf[LWS_PRE], msg_n, LWS_WRITE_TEXT);
}

void handle_server_data(char *in, size_t len){

	JSONObject *json = parseJSON(in);	
	if (json==NULL){
		printf("Error parsing json data : %s\n", (char*)in);
	}
	else{
		printf("Json parsed Count=%d\n", json->count);
		int mes_type = -1;
		char *id;
		char *errorObj;
		int i;
		
		for (i = 0; i < json->count; i++){
			
			if (strcmp(json->pairs[i].key, "mesType") == 0){
				mes_type = json->pairs[i].value->intValue;
				printf("Found mesType,intValue=%d\n", json->pairs[i].value->intValue);
			}
			else if (strcmp(json->pairs[i].key, "id") == 0)
				id = json->pairs[i].value->stringValue;					
			else if (strcmp(json->pairs[i].key, "errorObj") == 0)
				errorObj = json->pairs[i].value->stringValue;					
		}
		printf("MesType=%d, id=%s\n", mes_type,id);
		if (mes_type == MT_EVENT_NOTIFY){
			//event
		}
		else if (mes_type == MT_ERROR && errorObj){
			//error
			printf("Got error message from server: %s\n", (char*)errorObj);
		}
		else if (mes_type == MT_REGISTERED && id){
			//registration
			int n = strlen(id);
			if(n > REG_ID_MAX){
				printf("Registration id exceeds REG_ID_MAX!\n");
			}
			client_id = malloc((n+1)*sizeof(char));
			strcpy(client_id, id);
			printf("Client registered with id: %s\n",client_id);
		}
		
		freeJSONFromMemory(json);
	}

}
/*
 * Scheduled sul callback that starts the connection attempt
 */
static void connect_client(lws_sorted_usec_list_t *sul){
	struct my_conn *mco = lws_container_of(sul, struct my_conn, sul);
	struct lws_client_connect_info i;

	memset(&i, 0, sizeof(i));

	i.context = context;
	i.port = port;
	i.address = server_address;
	i.path = "/";
	i.host = i.address;
	i.origin = i.address;
	//i.ssl_connection = ssl_connection;
	i.protocol = pro;
	i.local_protocol_name = "beton-client";
	i.pwsi = &mco->wsi;
	i.retry_and_idle_policy = &retry;
	i.userdata = mco;

	if (!lws_client_connect_via_info(&i))
		/*
		 * Failed... schedule a retry... we can't use the _retry_wsi()
		 * convenience wrapper api here because no valid wsi at this
		 * point.
		 */
		if (lws_retry_sul_schedule(context, 0, sul, &retry,
					   connect_client, &mco->retry_count)) {
			lwsl_err("%s: connection attempts exhausted\n", __func__);
			interrupted = 1;
		}
}

static int on_callback(struct lws *wsi, enum lws_callback_reasons reason, void *user, void *in, size_t len){
	struct my_conn *mco = (struct my_conn *)user;
	
	switch (reason) {

	case LWS_CALLBACK_CLIENT_CONNECTION_ERROR:
		lwsl_err("CLIENT_CONNECTION_ERROR: %s\n",
			 in ? (char *)in : "(null)");
		goto do_retry;
		break;

	case LWS_CALLBACK_CLIENT_RECEIVE:
		//lwsl_hexdump_notice(in, len);		
		printf("Received data: %s\n", (char*)in);
		
		handle_server_data((char*)in, len);
		
		break;

	case LWS_CALLBACK_CLIENT_ESTABLISHED:
		lwsl_user("%s: established\n", __func__);
		
		cmd_register(wsi);
		/*
		//register command
		const char *token = "some_token";
		const unsigned int token_expires = 123456789;
		int msg_n = sprintf (resp_buf+LWS_PRE, "{\"cmd\":\"registerListener\",\"appId\":\"beton\",\"token\":\"%s\",\"tokenExpires\":\"%d\"}", token,token_expires);		
		lws_write(wsi, &resp_buf[LWS_PRE], msg_n, LWS_WRITE_TEXT);
		*/
		
		break;

	case LWS_CALLBACK_CLIENT_CLOSED:
		goto do_retry;

	default:
		break;
	}

	return lws_callback_http_dummy(wsi, reason, user, in, len);

do_retry:
	/*
	 * retry the connection to keep it nailed up
	 *
	 * For this example, we try to conceal any problem for one set of
	 * backoff retries and then exit the app.
	 *
	 * If you set retry.conceal_count to be larger than the number of
	 * elements in the backoff table, it will never give up and keep
	 * retrying at the last backoff delay plus the random jitter amount.
	 */
	if (lws_retry_sul_schedule_retry_wsi(wsi, &mco->sul, connect_client,
					     &mco->retry_count)) {
		lwsl_err("%s: connection attempts exhausted\n", __func__);
		interrupted = 1;
	}

	return 0;
}

static const struct lws_protocols protocols[] = {
	{ "beton-client"  		// Protocol name
	, on_callback			// Protocol callback
	, 0			 	// Data size per session (can be left empty)
	, 0,				// Receive buffer size (can be left empty)
	},
	{ NULL, NULL, 0, 0 }
};

static void sigint_handler(int sig){
	interrupted = 1;
}

int main(int argc, const char **argv){
	struct lws_context_creation_info info;
	const char *p;
	int n = 0;

	signal(SIGINT, sigint_handler);
	memset(&info, 0, sizeof info);
	lws_cmdline_option_handle_builtin(argc, argv, &info);

	lwsl_user("Beton route watcher\n");

	info.options = LWS_SERVER_OPTION_DO_SSL_GLOBAL_INIT;
	info.port = CONTEXT_PORT_NO_LISTEN; /* we do not run any server */
	info.protocols = protocols;

	if ((p = lws_cmdline_option(argc, argv, "-s")))
		server_address = p;

	if ((p = lws_cmdline_option(argc, argv, "-p")))
		port = atoi(p);

	info.fd_limit_per_thread = 1 + 1 + 1;

	context = lws_create_context(&info);
	if (!context) {
		lwsl_err("lws init failed\n");
		return 1;
	}

	// Allocating the memory for the response buffer
	memset(&resp_buf[LWS_PRE], 0, RESP_BUFFER_SIZE);

	/* schedule the first client connection attempt to happen immediately */
	lws_sul_schedule(context, 0, &mco.sul, connect_client, 1);

	while (n >= 0 && !interrupted)
		n = lws_service(context, 0);

	lws_context_destroy(context);
	lwsl_user("Completed\n");

	return 0;
}

