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

function RawMaterialStoreUserData_Controller(options){
	options = options || {};
	options.listModelClass = RawMaterialStoreUserDataList_Model;
	options.objModelClass = RawMaterialStoreUserDataList_Model;
	RawMaterialStoreUserData_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(RawMaterialStoreUserData_Controller,ControllerObjServer);

			RawMaterialStoreUserData_Controller.prototype.addInsert = function(){
	RawMaterialStoreUserData_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	
}

			RawMaterialStoreUserData_Controller.prototype.addUpdate = function(){
	RawMaterialStoreUserData_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_material_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	
}

			RawMaterialStoreUserData_Controller.prototype.addDelete = function(){
	RawMaterialStoreUserData_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("material_id",options));
}

			RawMaterialStoreUserData_Controller.prototype.addGetList = function(){
	RawMaterialStoreUserData_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldFloat("quant",f_opts));
}

			RawMaterialStoreUserData_Controller.prototype.addGetObject = function(){
	RawMaterialStoreUserData_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("material_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		