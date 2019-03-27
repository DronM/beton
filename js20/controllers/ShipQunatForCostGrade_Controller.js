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

function ShipQunatForCostGrade_Controller(options){
	options = options || {};
	options.listModelClass = ShipQunatForCostGrade_Model;
	options.objModelClass = ShipQunatForCostGrade_Model;
	ShipQunatForCostGrade_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ShipQunatForCostGrade_Controller,ControllerObjServer);

			ShipQunatForCostGrade_Controller.prototype.addInsert = function(){
	ShipQunatForCostGrade_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Объем";options.primaryKey = true;options.required = true;
	var field = new FieldInt("quant",options);
	
	pm.addField(field);
	
	
}

			ShipQunatForCostGrade_Controller.prototype.addUpdate = function(){
	ShipQunatForCostGrade_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Объем";options.primaryKey = true;
	var field = new FieldInt("quant",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_quant",{});
	pm.addField(field);
	
	
}

			ShipQunatForCostGrade_Controller.prototype.addDelete = function(){
	ShipQunatForCostGrade_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Объем";	
	pm.addField(new FieldInt("quant",options));
}

			ShipQunatForCostGrade_Controller.prototype.addGetList = function(){
	ShipQunatForCostGrade_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Объем";
	pm.addField(new FieldInt("quant",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("quant");
	
}

			ShipQunatForCostGrade_Controller.prototype.addGetObject = function(){
	ShipQunatForCostGrade_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Объем";	
	pm.addField(new FieldInt("quant",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		