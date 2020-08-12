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

function SMSForSending_Controller(options){
	options = options || {};
	options.listModelClass = SMSForSending_Model;
	SMSForSending_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
		
}
extend(SMSForSending_Controller,ControllerObjServer);

			SMSForSending_Controller.prototype.addGetList = function(){
	SMSForSending_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("tel",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("body",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("sent",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("sent_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("delivered",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("delivered_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("sms_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("sms_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("doc_ref",f_opts));
}

		