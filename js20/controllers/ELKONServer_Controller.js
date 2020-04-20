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

function ELKONServer_Controller(options){
	options = options || {};
	options.listModelClass = ELKONServer_Model;
	options.objModelClass = ELKONServer_Model;
	ELKONServer_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ELKONServer_Controller,ControllerObjServer);

			ELKONServer_Controller.prototype.addInsert = function(){
	ELKONServer_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование базы данных";options.required = true;
	var field = new FieldString("data_base_name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Имя пользователя";options.required = true;
	var field = new FieldString("user_name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пароль пользователя";options.required = true;
	var field = new FieldString("user_password",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "IP хоста";options.required = true;
	var field = new FieldString("host",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Порт хоста";options.required = true;
	var field = new FieldInt("port",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ELKONServer_Controller.prototype.addUpdate = function(){
	ELKONServer_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование базы данных";
	var field = new FieldString("data_base_name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Имя пользователя";
	var field = new FieldString("user_name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пароль пользователя";
	var field = new FieldString("user_password",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "IP хоста";
	var field = new FieldString("host",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Порт хоста";
	var field = new FieldInt("port",options);
	
	pm.addField(field);
	
	
}

			ELKONServer_Controller.prototype.addDelete = function(){
	ELKONServer_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			ELKONServer_Controller.prototype.addGetList = function(){
	ELKONServer_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Код";
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	f_opts.alias = "Наименование базы данных";
	pm.addField(new FieldString("data_base_name",f_opts));
	var f_opts = {};
	f_opts.alias = "Имя пользователя";
	pm.addField(new FieldString("user_name",f_opts));
	var f_opts = {};
	f_opts.alias = "Пароль пользователя";
	pm.addField(new FieldString("user_password",f_opts));
	var f_opts = {};
	f_opts.alias = "IP хоста";
	pm.addField(new FieldString("host",f_opts));
	var f_opts = {};
	f_opts.alias = "Порт хоста";
	pm.addField(new FieldInt("port",f_opts));
}

			ELKONServer_Controller.prototype.addGetObject = function(){
	ELKONServer_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		