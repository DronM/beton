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

function VehicleSchedule_Controller(options){
	options = options || {};
	options.listModelClass = VehicleScheduleList_Model;
	options.objModelClass = VehicleScheduleList_Model;
	VehicleSchedule_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addComplete();
	this.add_get_current_veh_list();
	this.addGetObject();
	this.add_set_free();
	this.add_set_out();
	this.add_gen_schedule();
	this.add_get_vehicle_efficiency();
	this.add_get_schedule_report();
	this.add_get_schedule_report_all();
	this.add_get_vehicle_runs();
		
}
extend(VehicleSchedule_Controller,ControllerObjServer);

			VehicleSchedule_Controller.prototype.addInsert = function(){
	VehicleSchedule_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDate("schedule_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автомобиль";options.required = true;
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Водитель";options.required = true;
	var field = new FieldInt("driver_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			VehicleSchedule_Controller.prototype.addUpdate = function(){
	VehicleSchedule_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDate("schedule_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автомобиль";
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Водитель";
	var field = new FieldInt("driver_id",options);
	
	pm.addField(field);
	
	
}

			VehicleSchedule_Controller.prototype.addDelete = function(){
	VehicleSchedule_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			VehicleSchedule_Controller.prototype.addGetList = function(){
	VehicleSchedule_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDate("schedule_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicles_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("driver_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("drivers_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("state",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("state_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("out_comment",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("load_capacity",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicle_owners_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("phone_cel",f_opts));
}

			VehicleSchedule_Controller.prototype.addComplete = function(){
	VehicleSchedule_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldString("vehicle_schedule_descr",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("vehicle_schedule_descr");	
}

			VehicleSchedule_Controller.prototype.add_get_current_veh_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_current_veh_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			VehicleSchedule_Controller.prototype.addGetObject = function(){
	VehicleSchedule_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			VehicleSchedule_Controller.prototype.add_set_free = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_free',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			VehicleSchedule_Controller.prototype.add_set_out = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_out',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldText("comment_text",options));
	
			
	this.addPublicMethod(pm);
}

			VehicleSchedule_Controller.prototype.add_gen_schedule = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('gen_schedule',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldDate("date_from",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldDate("date_to",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("vehicle_list",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day1",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day2",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day3",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day4",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day5",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day6",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("day7",options));
	
			
	this.addPublicMethod(pm);
}

			VehicleSchedule_Controller.prototype.add_get_vehicle_efficiency = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_vehicle_efficiency',opts);
	
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

			VehicleSchedule_Controller.prototype.add_get_schedule_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_schedule_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			VehicleSchedule_Controller.prototype.add_get_schedule_report_all = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_schedule_report_all',opts);
	
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

			VehicleSchedule_Controller.prototype.add_get_vehicle_runs = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_vehicle_runs',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

		