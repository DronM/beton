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

function OrderPump_Controller(options){
	options = options || {};
	options.listModelClass = OrderPumpList_Model;
	options.objModelClass = OrderPumpList_Model;
	OrderPump_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(OrderPump_Controller,ControllerObjServer);

			OrderPump_Controller.prototype.addInsert = function(){
	OrderPump_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("order_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("viewed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment",options);
	
	pm.addField(field);
	
	
}

			OrderPump_Controller.prototype.addUpdate = function(){
	OrderPump_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("order_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_order_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("viewed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment",options);
	
	pm.addField(field);
	
	
}

			OrderPump_Controller.prototype.addDelete = function(){
	OrderPump_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("order_id",options));
}

			OrderPump_Controller.prototype.addGetList = function(){
	OrderPump_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("order_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("destination_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("destinations_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("concrete_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("concrete_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("unload_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("phone_cel",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("viewed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
}

			OrderPump_Controller.prototype.addGetObject = function(){
	OrderPump_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("order_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		