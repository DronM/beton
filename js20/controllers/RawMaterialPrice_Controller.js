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

function RawMaterialPrice_Controller(options){
	options = options || {};
	options.listModelClass = RawMaterialPriceList_Model;
	options.objModelClass = RawMaterialPriceList_Model;
	RawMaterialPrice_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(RawMaterialPrice_Controller,ControllerObjServer);

			RawMaterialPrice_Controller.prototype.addInsert = function(){
	RawMaterialPrice_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";options.required = true;
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материал";options.required = true;
	var field = new FieldInt("raw_material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Цена";
	var field = new FieldFloat("price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата установки";
	var field = new FieldDateTime("set_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пользователь";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			RawMaterialPrice_Controller.prototype.addUpdate = function(){
	RawMaterialPrice_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материал";
	var field = new FieldInt("raw_material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Цена";
	var field = new FieldFloat("price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата установки";
	var field = new FieldDateTime("set_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Пользователь";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	
}

			RawMaterialPrice_Controller.prototype.addDelete = function(){
	RawMaterialPrice_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			RawMaterialPrice_Controller.prototype.addGetList = function(){
	RawMaterialPrice_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Дата";
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("raw_material_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Материал";
	pm.addField(new FieldJSON("raw_materials_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Цена";
	pm.addField(new FieldFloat("price",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата установки";
	pm.addField(new FieldDateTime("set_date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Пользователь";
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("users_ref",f_opts));
}

			RawMaterialPrice_Controller.prototype.addGetObject = function(){
	RawMaterialPrice_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		