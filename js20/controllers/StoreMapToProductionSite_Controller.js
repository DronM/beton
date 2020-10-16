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

function StoreMapToProductionSite_Controller(options){
	options = options || {};
	options.listModelClass = StoreMapToProductionSiteList_Model;
	options.objModelClass = StoreMapToProductionSiteList_Model;
	StoreMapToProductionSite_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(StoreMapToProductionSite_Controller,ControllerObjServer);

			StoreMapToProductionSite_Controller.prototype.addInsert = function(){
	StoreMapToProductionSite_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Склад весов";options.required = true;
	var field = new FieldText("store",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Завод";
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Масса загружаемого материала,т.";
	var field = new FieldInt("load_capacity",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			StoreMapToProductionSite_Controller.prototype.addUpdate = function(){
	StoreMapToProductionSite_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Склад весов";
	var field = new FieldText("store",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Завод";
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Масса загружаемого материала,т.";
	var field = new FieldInt("load_capacity",options);
	
	pm.addField(field);
	
	
}

			StoreMapToProductionSite_Controller.prototype.addDelete = function(){
	StoreMapToProductionSite_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			StoreMapToProductionSite_Controller.prototype.addGetList = function(){
	StoreMapToProductionSite_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Код";
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	f_opts.alias = "Склад весов";
	pm.addField(new FieldText("store",f_opts));
	var f_opts = {};
	f_opts.alias = "Завод";
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Масса загружаемого материала,т.";
	pm.addField(new FieldInt("load_capacity",f_opts));
}

			StoreMapToProductionSite_Controller.prototype.addGetObject = function(){
	StoreMapToProductionSite_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		