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

function ELKONLog_Controller(options){
	options = options || {};
	options.listModelClass = ELKONLogList_Model;
	options.objModelClass = ELKONLogList_Model;
	ELKONLog_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
	this.addGetObject();
		
}
extend(ELKONLog_Controller,ControllerObjServer);

			ELKONLog_Controller.prototype.addGetList = function(){
	ELKONLog_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("message",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("level",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			ELKONLog_Controller.prototype.addGetObject = function(){
	ELKONLog_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		