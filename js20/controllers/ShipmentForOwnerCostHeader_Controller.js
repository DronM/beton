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

function ShipmentForOwnerCostHeader_Controller(options){
	options = options || {};
	options.listModelClass = ShipmentForOwnerCostHeader_Model;
	options.objModelClass = ShipmentForOwnerCostHeader_Model;
	ShipmentForOwnerCostHeader_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ShipmentForOwnerCostHeader_Controller,ControllerObjServer);

			ShipmentForOwnerCostHeader_Controller.prototype.addInsert = function(){
	ShipmentForOwnerCostHeader_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			ShipmentForOwnerCostHeader_Controller.prototype.addUpdate = function(){
	ShipmentForOwnerCostHeader_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	field = new FieldDate("old_date",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			ShipmentForOwnerCostHeader_Controller.prototype.addDelete = function(){
	ShipmentForOwnerCostHeader_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldDate("date",options));
}

			ShipmentForOwnerCostHeader_Controller.prototype.addGetList = function(){
	ShipmentForOwnerCostHeader_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDate("date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
}

			ShipmentForOwnerCostHeader_Controller.prototype.addGetObject = function(){
	ShipmentForOwnerCostHeader_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldDate("date",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		