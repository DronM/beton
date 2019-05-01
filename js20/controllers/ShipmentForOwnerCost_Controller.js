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

function ShipmentForOwnerCost_Controller(options){
	options = options || {};
	options.listModelClass = ShipmentForOwnerCost_Model;
	options.objModelClass = ShipmentForOwnerCost_Model;
	ShipmentForOwnerCost_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ShipmentForOwnerCost_Controller,ControllerObjServer);

			ShipmentForOwnerCost_Controller.prototype.addInsert = function(){
	ShipmentForOwnerCost_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("distance_to",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("price",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ShipmentForOwnerCost_Controller.prototype.addUpdate = function(){
	ShipmentForOwnerCost_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("distance_to",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("price",options);
	
	pm.addField(field);
	
	
}

			ShipmentForOwnerCost_Controller.prototype.addDelete = function(){
	ShipmentForOwnerCost_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ShipmentForOwnerCost_Controller.prototype.addGetList = function(){
	ShipmentForOwnerCost_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDate("date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("distance_to",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("price",f_opts));
}

			ShipmentForOwnerCost_Controller.prototype.addGetObject = function(){
	ShipmentForOwnerCost_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		