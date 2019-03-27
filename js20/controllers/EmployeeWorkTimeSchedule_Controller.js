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

function EmployeeWorkTimeSchedule_Controller(options){
	options = options || {};
	options.listModelClass = EmployeeWorkTimeScheduleList_Model;
	EmployeeWorkTimeSchedule_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
		
}
extend(EmployeeWorkTimeSchedule_Controller,ControllerObjServer);

			EmployeeWorkTimeSchedule_Controller.prototype.addInsert = function(){
	EmployeeWorkTimeSchedule_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDate("day",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("hours",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			EmployeeWorkTimeSchedule_Controller.prototype.addUpdate = function(){
	EmployeeWorkTimeSchedule_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("day",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("hours",options);
	
	pm.addField(field);
	
	
}

			EmployeeWorkTimeSchedule_Controller.prototype.addDelete = function(){
	EmployeeWorkTimeSchedule_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			EmployeeWorkTimeSchedule_Controller.prototype.addGetList = function(){
	EmployeeWorkTimeSchedule_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Сотрудник";
	pm.addField(new FieldString("employee_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("day",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldString("day_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Часы";
	pm.addField(new FieldInt("hours",f_opts));
}

		