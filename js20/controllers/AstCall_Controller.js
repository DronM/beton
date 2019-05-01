/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjServer
  
 * @requires core/extend.js
 * @requires core/ControllerObjServer.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function AstCall_Controller(options){
	options = options || {};
	options.listModelClass = AstCallList_Model;
	options.objModelClass = AstCallList_Model;
	AstCall_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addGetList();
	this.addGetObject();
	this.add_client_call_hist();
	this.add_client_ship_hist();
	this.add_active_call();
	this.add_active_call_inform();
	this.add_set_active_call_client_kind();
	this.add_new_client();
	this.add_manager_report();
	this.add_restart_ast();
		
}
extend(AstCall_Controller,ControllerObjServer);

			AstCall_Controller.prototype.addUpdate = function(){
	AstCall_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldText("unique_id",options);
	
	pm.addField(field);
	
	field = new FieldText("old_unique_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("caller_id_num",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ext",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTime("start_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTime("end_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'in,out';
	
	var field = new FieldEnum("call_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id_to",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("answer_unique_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTime("dt",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("manager_comment",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("informed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("create_date",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldString("contact_name",options));
	
		var options = {};
				
		pm.addField(new FieldString("contact_tel",options));
	
		var options = {};
				
		pm.addField(new FieldString("client_name",options));
	
		var options = {};
				
		pm.addField(new FieldEnum("client_kind",options));
	
		var options = {};
				
		pm.addField(new FieldInt("client_come_from_id",options));
	
		var options = {};
				
		pm.addField(new FieldInt("client_type_id",options));
	
		var options = {};
				
		pm.addField(new FieldString("manager_comment",options));
	
	
}

			AstCall_Controller.prototype.addGetList = function(){
	AstCall_Controller.superclass.addGetList.call(this);
	
	
	
	var pm = this.getGetList();
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	var f_opts = {};
	
	pm.addField(new FieldText("unique_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("call_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("start_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("end_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldTime("dur_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("manager_comment",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("client_comment",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("client_create_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("ours",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("client_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("client_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("client_come_from_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("client_come_from_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("client_kind",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("caller_id_num",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("ext",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("num",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("offer_quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("offer_total",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("offer_result",f_opts));
		var options = {};
						
		pm.addField(new FieldString("new_clients",options));
	
	pm.getField(this.PARAM_ORD_FIELDS).setValue("start_time");
	
}

			AstCall_Controller.prototype.addGetObject = function(){
	AstCall_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldText("unique_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			AstCall_Controller.prototype.add_client_call_hist = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('client_call_hist',opts);
	
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_client_ship_hist = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('client_ship_hist',opts);
	
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_active_call = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('active_call',opts);
	
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_active_call_inform = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('active_call_inform',opts);
	
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_set_active_call_client_kind = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_active_call_client_kind',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("kind",options));
	
			
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_new_client = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('new_client',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("ast_call_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("client_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("client_name",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("contact_name",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("client_type_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("client_come_from_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("client_comment_text",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("destination_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("concrete_type_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("unload_type",options));
	
				
	
	var options = {};
	
		options.maxlength = "15";
	
		pm.addField(new FieldFloat("concrete_price",options));
	
				
	
	var options = {};
	
		options.maxlength = "15";
	
		pm.addField(new FieldFloat("destination_price",options));
	
				
	
	var options = {};
	
		options.maxlength = "15";
	
		pm.addField(new FieldFloat("unload_price",options));
	
				
	
	var options = {};
	
		options.maxlength = "15";
	
		pm.addField(new FieldFloat("total",options));
	
				
	
	var options = {};
	
		options.maxlength = "19";
	
		pm.addField(new FieldFloat("quant",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("offer_result",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("comment_text",options));
	
			
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_manager_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('manager_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

			AstCall_Controller.prototype.add_restart_ast = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('restart_ast',opts);
	
	this.addPublicMethod(pm);
}

		