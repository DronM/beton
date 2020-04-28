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

function Production_Controller(options){
	options = options || {};
	options.listModelClass = ProductionList_Model;
	options.objModelClass = ProductionList_Model;
	Production_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_check_data();
	this.add_check_production();
	this.add_get_production_material_list();
		
}
extend(Production_Controller,ControllerObjServer);

			Production_Controller.prototype.addInsert = function(){
	Production_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Elkon production ID";options.required = true;
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Начало производства в Elkon";options.required = true;
	var field = new FieldDateTimeTZ("production_dt_start",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Окончание производства в Elkon";
	var field = new FieldDateTimeTZ("production_dt_end",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пользователь Elkon";
	var field = new FieldString("production_user",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ТС в Elkon";options.required = true;
	var field = new FieldString("production_vehicle_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("dt_start_set",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("dt_end_set",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_schedule_state_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("production_concrete_type_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("material_tolerance_violated",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Production_Controller.prototype.addUpdate = function(){
	Production_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Elkon production ID";
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Начало производства в Elkon";
	var field = new FieldDateTimeTZ("production_dt_start",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Окончание производства в Elkon";
	var field = new FieldDateTimeTZ("production_dt_end",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пользователь Elkon";
	var field = new FieldString("production_user",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ТС в Elkon";
	var field = new FieldString("production_vehicle_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("dt_start_set",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("dt_end_set",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_schedule_state_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("production_concrete_type_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("material_tolerance_violated",options);
	
	pm.addField(field);
	
	
}

			Production_Controller.prototype.addDelete = function(){
	Production_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Production_Controller.prototype.addGetList = function(){
	Production_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("production_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("production_dt_start",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("production_dt_end",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("production_user",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("production_vehicle_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("dt_start_set",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("dt_end_set",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("shipments_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicle_schedules_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("orders_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("concrete_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("production_concrete_type_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("concrete_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("order_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("material_tolerance_violated",f_opts));
}

			Production_Controller.prototype.addGetObject = function(){
	Production_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Production_Controller.prototype.add_check_data = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('check_data',opts);
	
	this.addPublicMethod(pm);
}

			Production_Controller.prototype.add_check_production = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('check_production',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("production_site_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("production_id",options));
	
			
	this.addPublicMethod(pm);
}

			Production_Controller.prototype.add_get_production_material_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_production_material_list',opts);
	
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

		