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

function ProductionVehicleCorrection_Controller(options){
	options = options || {};
	options.listModelClass = ProductionVehicleCorrectionList_Model;
	options.objModelClass = ProductionVehicleCorrectionList_Model;
	ProductionVehicleCorrection_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ProductionVehicleCorrection_Controller,ControllerObjServer);

			ProductionVehicleCorrection_Controller.prototype.addInsert = function(){
	ProductionVehicleCorrection_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	
}

			ProductionVehicleCorrection_Controller.prototype.addUpdate = function(){
	ProductionVehicleCorrection_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_production_site_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_production_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	
}

			ProductionVehicleCorrection_Controller.prototype.addDelete = function(){
	ProductionVehicleCorrection_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("production_site_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("production_id",options));
}

			ProductionVehicleCorrection_Controller.prototype.addGetList = function(){
	ProductionVehicleCorrection_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Завод";
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Номер производства";
	pm.addField(new FieldInt("production_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_id",f_opts));
	var f_opts = {};
	f_opts.alias = "ТС";
	pm.addField(new FieldJSON("vehicles_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата установки";
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Пользователь";
	pm.addField(new FieldJSON("users_ref",f_opts));
}

			ProductionVehicleCorrection_Controller.prototype.addGetObject = function(){
	ProductionVehicleCorrection_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Номер производства";	
	pm.addField(new FieldInt("production_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		