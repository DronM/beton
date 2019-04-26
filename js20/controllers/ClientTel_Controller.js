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

function ClientTel_Controller(options){
	options = options || {};
	options.listModelClass = ClientTelList_Model;
	options.objModelClass = ClientTel_Model;
	ClientTel_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ClientTel_Controller,ControllerObjServer);

			ClientTel_Controller.prototype.addInsert = function(){
	ClientTel_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ФИО";
	var field = new FieldText("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Телефон";options.required = true;
	var field = new FieldString("tel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Эл.почта";
	var field = new FieldString("email",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Должность";
	var field = new FieldString("post",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ClientTel_Controller.prototype.addUpdate = function(){
	ClientTel_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ФИО";
	var field = new FieldText("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Телефон";
	var field = new FieldString("tel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Эл.почта";
	var field = new FieldString("email",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Должность";
	var field = new FieldString("post",options);
	
	pm.addField(field);
	
	
}

			ClientTel_Controller.prototype.addDelete = function(){
	ClientTel_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ClientTel_Controller.prototype.addGetList = function(){
	ClientTel_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "ФИО";
	pm.addField(new FieldText("name",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("tel",f_opts));
	var f_opts = {};
	f_opts.alias = "Эл.почта";
	pm.addField(new FieldString("email",f_opts));
	var f_opts = {};
	f_opts.alias = "Должность";
	pm.addField(new FieldString("post",f_opts));
}

			ClientTel_Controller.prototype.addGetObject = function(){
	ClientTel_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		