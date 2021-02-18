<?php
//$a = json_encode(["params"=>["id"=>1,"descr"=>"aaa"]]);
//throw new Exception($a);
require_once(dirname(__FILE__).'/functions/BetonEventSrv.php');
BetonEventSrv::publish('Client.update',['id'=>1050]);//publishAsync



/*
require "Config.php";
require FRAME_WORK_PATH."basic_classes/websocket_client.php";
$server = '127.0.0.1';
$message = "hello server";

echo var_export($_GET,TRUE);

if( $sp = websocket_open($server, 1337) ) {
  echo "Sending message to server: '$message' \n";
  websocket_write($sp,json_encode($_GET));
  echo "Server responed with: '" . websocket_read($sp,$errstr) ."'\n";
}else {
  echo "Failed to connect to server\n";
  echo "Server responed with: $errstr\n";
}
*/

?>
