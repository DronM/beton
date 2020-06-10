/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjClient
  
 * @requires core/extend.js
 * @requires core/ControllerObjClient.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function ClientList_Controller(options){
	options = options || {};
	options.listModelClass = ClientList_Model;
	options.objModelClass = ClientList_Model;
	ClientList_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ClientList_Controller,ControllerObjClient);

			ClientList_Controller.prototype.addInsert = function(){
	ClientList_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Телефон";
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Объем";
	var field = new FieldString("quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("client_types_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Источник";
	var field = new FieldJSON("client_come_from_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_come_from_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид клиента";
	var field = new FieldString("client_kind",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наш";
	var field = new FieldString("ours",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Первое обращение";
	var field = new FieldDate("first_call_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Кто завел";
	var field = new FieldJSON("users_ref",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ИНН";
	var field = new FieldString("inn",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("client",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ClientList_Controller.prototype.addUpdate = function(){
	ClientList_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Телефон";
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Объем";
	var field = new FieldString("quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("client_types_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Источник";
	var field = new FieldJSON("client_come_from_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_come_from_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид клиента";
	var field = new FieldString("client_kind",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наш";
	var field = new FieldString("ours",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Первое обращение";
	var field = new FieldDate("first_call_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Кто завел";
	var field = new FieldJSON("users_ref",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ИНН";
	var field = new FieldString("inn",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("client",options);
	
	pm.addField(field);
	
	
}

			ClientList_Controller.prototype.addDelete = function(){
	ClientList_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ClientList_Controller.prototype.addGetList = function(){
	ClientList_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	f_opts.alias = "Наименование";
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("phone_cel",f_opts));
	var f_opts = {};
	f_opts.alias = "Объем";
	pm.addField(new FieldString("quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("client_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_type_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Источник";
	pm.addField(new FieldJSON("client_come_from_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_come_from_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Вид клиента";
	pm.addField(new FieldString("client_kind",f_opts));
	var f_opts = {};
	f_opts.alias = "Наш";
	pm.addField(new FieldString("ours",f_opts));
	var f_opts = {};
	f_opts.alias = "Первое обращение";
	pm.addField(new FieldDate("first_call_date",f_opts));
	var f_opts = {};
	f_opts.alias = "Кто завел";
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "ИНН";
	pm.addField(new FieldString("inn",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("client",f_opts));
}

			ClientList_Controller.prototype.addGetObject = function(){
	ClientList_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		