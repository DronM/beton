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

function Vehicle_Controller(options){
	options = options || {};
	options.listModelClass = VehicleDialog_Model;
	options.objModelClass = VehicleDialog_Model;
	Vehicle_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
	this.add_get_vehicle_statistics();
	this.add_complete_features();
	this.add_complete_makes();
	this.add_check_for_broken_trackers();
	this.add_vehicles_with_trackers();
	this.add_get_current_position();
	this.add_get_current_position_all();
	this.add_get_track();
	this.add_get_tool_tip();
	this.add_get_stops_at_dest();
		
}
extend(Vehicle_Controller,ControllerObjServer);

			Vehicle_Controller.prototype.addInsert = function(){
	Vehicle_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер";options.required = true;
	var field = new FieldString("plate",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер число для сортировки";
	var field = new FieldInt("plate_n",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Грузоподъемность";options.required = true;
	var field = new FieldFloat("load_capacity",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Марка";
	var field = new FieldString("make",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("driver_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Свойство";
	var field = new FieldString("feature",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Трэкер";
	var field = new FieldString("tracker_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Идентификатор SIM карты";
	var field = new FieldString("sim_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер телефона SIM карты";
	var field = new FieldString("sim_number",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "УДАЛИТЬ Владелец";
	var field = new FieldInt("vehicle_owner_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "История владелецев";
	var field = new FieldJSONB("vehicle_owners",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("vehicle_owners_ar",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Vehicle_Controller.prototype.addUpdate = function(){
	Vehicle_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер";
	var field = new FieldString("plate",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер число для сортировки";
	var field = new FieldInt("plate_n",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Грузоподъемность";
	var field = new FieldFloat("load_capacity",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Марка";
	var field = new FieldString("make",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("driver_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Свойство";
	var field = new FieldString("feature",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Трэкер";
	var field = new FieldString("tracker_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Идентификатор SIM карты";
	var field = new FieldString("sim_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер телефона SIM карты";
	var field = new FieldString("sim_number",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "УДАЛИТЬ Владелец";
	var field = new FieldInt("vehicle_owner_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "История владелецев";
	var field = new FieldJSONB("vehicle_owners",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("vehicle_owners_ar",options);
	
	pm.addField(field);
	
	
}

			Vehicle_Controller.prototype.addDelete = function(){
	Vehicle_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Vehicle_Controller.prototype.addGetList = function(){
	Vehicle_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Номер";
	pm.addField(new FieldString("plate",f_opts));
	var f_opts = {};
	f_opts.alias = "Грузоподъемность";
	pm.addField(new FieldFloat("load_capacity",f_opts));
	var f_opts = {};
	f_opts.alias = "Марка";
	pm.addField(new FieldString("make",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("drivers_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Свойство";
	pm.addField(new FieldString("feature",f_opts));
	var f_opts = {};
	f_opts.alias = "Трэкер";
	pm.addField(new FieldString("tracker_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Идентификатор SIM карты";
	pm.addField(new FieldString("sim_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Номер телефона SIM карты";
	pm.addField(new FieldString("sim_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("tracker_last_dt",f_opts));
	var f_opts = {};
	f_opts.alias = "Последний владелец";
	pm.addField(new FieldJSONB("vehicle_owners_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Последний владелец";
	pm.addField(new FieldInt("vehicle_owner_id",f_opts));
	var f_opts = {};
	f_opts.alias = "История владелецев";
	pm.addField(new FieldJSONB("vehicle_owners",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldArray("vehicle_owners_ar",f_opts));
}

			Vehicle_Controller.prototype.addGetObject = function(){
	Vehicle_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Vehicle_Controller.prototype.addComplete = function(){
	Vehicle_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("plate",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("plate");	
}

			Vehicle_Controller.prototype.add_get_vehicle_statistics = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_vehicle_statistics',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_complete_features = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_features',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("feature",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_complete_makes = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_makes',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("make",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_check_for_broken_trackers = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('check_for_broken_trackers',opts);
	
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_vehicles_with_trackers = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('vehicles_with_trackers',opts);
	
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_get_current_position = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_current_position',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_get_current_position_all = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_current_position_all',opts);
	
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_get_track = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_track',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDateTime("dt_from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDateTime("dt_to",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldTime("stop_dur",options));
	
			
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_get_tool_tip = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_tool_tip',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Vehicle_Controller.prototype.add_get_stops_at_dest = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_stops_at_dest',opts);
	
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

		