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

function PumpVehicle_Controller(options){
	options = options || {};
	options.listModelClass = PumpVehicleList_Model;
	options.objModelClass = PumpVehicleList_Model;
	PumpVehicle_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.add_get_work_list();
	this.addGetObject();
	this.add_get_price();
		
}
extend(PumpVehicle_Controller,ControllerObjServer);

			PumpVehicle_Controller.prototype.addInsert = function(){
	PumpVehicle_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("pump_price_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("pump_length",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("deleted",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("phone_cels",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			PumpVehicle_Controller.prototype.addUpdate = function(){
	PumpVehicle_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("pump_price_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("pump_length",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("deleted",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("phone_cels",options);
	
	pm.addField(field);
	
	
}

			PumpVehicle_Controller.prototype.addDelete = function(){
	PumpVehicle_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			PumpVehicle_Controller.prototype.addGetList = function(){
	PumpVehicle_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("phone_cel",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("pump_prices_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("pump_vehicles_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicle_owners_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("feature",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("make",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("plate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("deleted",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("pump_length",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_owner_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("phone_cels",f_opts));
}

			PumpVehicle_Controller.prototype.add_get_work_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_work_list',opts);
	
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

			PumpVehicle_Controller.prototype.addGetObject = function(){
	PumpVehicle_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			PumpVehicle_Controller.prototype.add_get_price = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_price',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("pump_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "19";
	
		pm.addField(new FieldFloat("quant",options));
	
			
	this.addPublicMethod(pm);
}

		