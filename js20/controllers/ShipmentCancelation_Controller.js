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

function ShipmentCancelation_Controller(options){
	options = options || {};
	options.listModelClass = ShipmentCancelationList_Model;
	options.objModelClass = ShipmentCancelationList_Model;
	ShipmentCancelation_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ShipmentCancelation_Controller,ControllerObjServer);

			ShipmentCancelation_Controller.prototype.addInsert = function(){
	ShipmentCancelation_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата отгрузки";
	var field = new FieldDateTimeTZ("ship_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Заявка";options.required = true;
	var field = new FieldInt("order_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Экипаж";options.required = true;
	var field = new FieldInt("vehicle_schedule_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";options.required = true;
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пользователь";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ShipmentCancelation_Controller.prototype.addUpdate = function(){
	ShipmentCancelation_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата отгрузки";
	var field = new FieldDateTimeTZ("ship_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Заявка";
	var field = new FieldInt("order_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Экипаж";
	var field = new FieldInt("vehicle_schedule_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пользователь";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	
}

			ShipmentCancelation_Controller.prototype.addDelete = function(){
	ShipmentCancelation_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			ShipmentCancelation_Controller.prototype.addGetList = function(){
	ShipmentCancelation_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Дата";
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата отгрузки";
	pm.addField(new FieldDateTimeTZ("ship_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("order_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Заявка";
	pm.addField(new FieldJSON("orders_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_schedule_id",f_opts));
	var f_opts = {};
	f_opts.alias = "ТС,водитель";
	pm.addField(new FieldJSON("vehicle_schedules_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Пользователь";
	pm.addField(new FieldJSON("users_ref",f_opts));
}

			ShipmentCancelation_Controller.prototype.addGetObject = function(){
	ShipmentCancelation_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		