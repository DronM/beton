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

function DOCMaterialInventoryDOCTMaterial_Controller(options){
	options = options || {};
	options.listModelClass = DOCMaterialInventoryDOCTMaterialList_Model;
	options.objModelClass = DOCMaterialInventoryDOCTMaterialList_Model;
	DOCMaterialInventoryDOCTMaterial_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(DOCMaterialInventoryDOCTMaterial_Controller,ControllerObjServer);

			DOCMaterialInventoryDOCTMaterial_Controller.prototype.addInsert = function(){
	DOCMaterialInventoryDOCTMaterial_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("login_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("line_number",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материал";options.required = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Количество";
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	
}

			DOCMaterialInventoryDOCTMaterial_Controller.prototype.addUpdate = function(){
	DOCMaterialInventoryDOCTMaterial_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("login_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_login_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("line_number",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_line_number",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Материал";
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Количество";
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	
}

			DOCMaterialInventoryDOCTMaterial_Controller.prototype.addDelete = function(){
	DOCMaterialInventoryDOCTMaterial_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("login_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("line_number",options));
}

			DOCMaterialInventoryDOCTMaterial_Controller.prototype.addGetList = function(){
	DOCMaterialInventoryDOCTMaterial_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("login_id",f_opts));
	var f_opts = {};
	f_opts.alias = "№";
	pm.addField(new FieldInt("line_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("material_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("material_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("quant",f_opts));
}

			DOCMaterialInventoryDOCTMaterial_Controller.prototype.addGetObject = function(){
	DOCMaterialInventoryDOCTMaterial_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "№";	
	pm.addField(new FieldInt("line_number",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		