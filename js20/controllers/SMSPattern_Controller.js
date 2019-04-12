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

function SMSPattern_Controller(options){
	options = options || {};
	options.listModelClass = SMSPatternList_Model;
	options.objModelClass = SMSPatternList_Model;
	SMSPattern_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(SMSPattern_Controller,ControllerObjServer);

			SMSPattern_Controller.prototype.addInsert = function(){
	SMSPattern_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Язык";options.required = true;
	var field = new FieldInt("lang_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Тип SMS";options.required = true;	
	options.enumValues = 'order,ship,remind,procur,order_for_pump_ins,order_for_pump_upd,order_for_pump_del,remind_for_pump,client_thank,vehicle_zone_violation,vehicle_tracker_malfunction,efficiency_warn,material_balance';
	var field = new FieldEnum("sms_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Шаблон";options.required = true;
	var field = new FieldText("pattern",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			SMSPattern_Controller.prototype.addUpdate = function(){
	SMSPattern_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Язык";
	var field = new FieldInt("lang_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Тип SMS";	
	options.enumValues = 'order,ship,remind,procur,order_for_pump_ins,order_for_pump_upd,order_for_pump_del,remind_for_pump,client_thank,vehicle_zone_violation,vehicle_tracker_malfunction,efficiency_warn,material_balance';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("sms_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Шаблон";
	var field = new FieldText("pattern",options);
	
	pm.addField(field);
	
	
}

			SMSPattern_Controller.prototype.addDelete = function(){
	SMSPattern_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			SMSPattern_Controller.prototype.addGetList = function(){
	SMSPattern_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("sms_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("langs_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("pattern",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("user_list",f_opts));
}

			SMSPattern_Controller.prototype.addGetObject = function(){
	SMSPattern_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		