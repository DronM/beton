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

function VehicleOwnerConcretePrice_Controller(options){
	options = options || {};
	options.listModelClass = VehicleOwnerConcretePriceList_Model;
	options.objModelClass = VehicleOwnerConcretePriceList_Model;
	VehicleOwnerConcretePrice_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(VehicleOwnerConcretePrice_Controller,ControllerObjServer);

			VehicleOwnerConcretePrice_Controller.prototype.addInsert = function(){
	VehicleOwnerConcretePrice_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("vehicle_owner_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("concrete_costs_for_owner_h_id",options);
	
	pm.addField(field);
	
	
}

			VehicleOwnerConcretePrice_Controller.prototype.addUpdate = function(){
	VehicleOwnerConcretePrice_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("vehicle_owner_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_vehicle_owner_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_client_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	field = new FieldDate("old_date",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("concrete_costs_for_owner_h_id",options);
	
	pm.addField(field);
	
	
}

			VehicleOwnerConcretePrice_Controller.prototype.addDelete = function(){
	VehicleOwnerConcretePrice_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("vehicle_owner_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("client_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldDate("date",options));
}

			VehicleOwnerConcretePrice_Controller.prototype.addGetList = function(){
	VehicleOwnerConcretePrice_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("vehicle_owner_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicle_owners_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("concrete_costs_for_owner_h_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
}

			VehicleOwnerConcretePrice_Controller.prototype.addGetObject = function(){
	VehicleOwnerConcretePrice_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("vehicle_owner_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldDate("date",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		