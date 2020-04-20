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

function MaterialFactConsumption_Controller(options){
	options = options || {};
	options.listModelClass = MaterialFactConsumptionList_Model;
	options.objModelClass = MaterialFactConsumptionList_Model;
	MaterialFactConsumption_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.add_get_rolled_list();
	this.addGetObject();
	this.add_upload_production_file();
	this.add_get_report();
		
}
extend(MaterialFactConsumption_Controller,ControllerObjServer);

			MaterialFactConsumption_Controller.prototype.addInsert = function(){
	MaterialFactConsumption_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTimeTZ("upload_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("upload_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("concrete_type_production_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("raw_material_production_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("raw_material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("vehicle_production_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_schedule_state_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("concrete_quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("material_quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("material_quant_req",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cement_silo_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			MaterialFactConsumption_Controller.prototype.addUpdate = function(){
	MaterialFactConsumption_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("upload_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("upload_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("concrete_type_production_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("raw_material_production_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("raw_material_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("vehicle_production_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_schedule_state_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("concrete_quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("material_quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("material_quant_req",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cement_silo_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	
}

			MaterialFactConsumption_Controller.prototype.addDelete = function(){
	MaterialFactConsumption_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			MaterialFactConsumption_Controller.prototype.addGetList = function(){
	MaterialFactConsumption_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("upload_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("upload_users_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("orders_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("shipments_inf",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("concrete_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("concrete_type_production_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("raw_materials_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("raw_material_production_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicles_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("vehicle_production_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("concrete_quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("material_quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("material_quant_req",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("material_quant_shipped",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("material_quant_tolerance_exceeded",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("err_concrete_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("order_concrete_types_ref",f_opts));
}

			MaterialFactConsumption_Controller.prototype.add_get_rolled_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_rolled_list',opts);
	
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

			MaterialFactConsumption_Controller.prototype.addGetObject = function(){
	MaterialFactConsumption_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			MaterialFactConsumption_Controller.prototype.add_upload_production_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('upload_production_file',opts);
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("production_site_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("production_file",options));
	
			
	this.addPublicMethod(pm);
}

			MaterialFactConsumption_Controller.prototype.add_get_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_report',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("production_site_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("production_file",options));
	
			
	this.addPublicMethod(pm);
}

		