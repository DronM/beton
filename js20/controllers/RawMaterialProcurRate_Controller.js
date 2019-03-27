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

function RawMaterialProcurRate_Controller(options){
	options = options || {};
	options.listModelClass = RawMaterialProcurRateList_Model;
	options.objModelClass = RawMaterialProcurRateList_Model;
	RawMaterialProcurRate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(RawMaterialProcurRate_Controller,ControllerObjServer);

			RawMaterialProcurRate_Controller.prototype.addInsert = function(){
	RawMaterialProcurRate_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("supplier_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("rate",options);
	
	pm.addField(field);
	
	
}

			RawMaterialProcurRate_Controller.prototype.addUpdate = function(){
	RawMaterialProcurRate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_material_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("supplier_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_supplier_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("rate",options);
	
	pm.addField(field);
	
	
}

			RawMaterialProcurRate_Controller.prototype.addDelete = function(){
	RawMaterialProcurRate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("material_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("supplier_id",options));
}

			RawMaterialProcurRate_Controller.prototype.addGetList = function(){
	RawMaterialProcurRate_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("material_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("material_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("supplier_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("rate",f_opts));
}

			RawMaterialProcurRate_Controller.prototype.addGetObject = function(){
	RawMaterialProcurRate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("material_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldInt("supplier_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		