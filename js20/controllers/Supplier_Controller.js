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

function Supplier_Controller(options){
	options = options || {};
	options.listModelClass = SupplierList_Model;
	options.objModelClass = Supplier_Model;
	Supplier_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
		
}
extend(Supplier_Controller,ControllerObjServer);

			Supplier_Controller.prototype.addInsert = function(){
	Supplier_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";options.required = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Полное наименование";options.required = true;
	var field = new FieldText("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Мобильный телефон";
	var field = new FieldString("tel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Мобильный телефон";
	var field = new FieldString("tel2",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("lang_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ext_ref_scales",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Supplier_Controller.prototype.addUpdate = function(){
	Supplier_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Полное наименование";
	var field = new FieldText("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Мобильный телефон";
	var field = new FieldString("tel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Мобильный телефон";
	var field = new FieldString("tel2",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("lang_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ext_ref_scales",options);
	
	pm.addField(field);
	
	
}

			Supplier_Controller.prototype.addDelete = function(){
	Supplier_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			Supplier_Controller.prototype.addGetList = function(){
	Supplier_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Наименование";
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("tel",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("tel2",f_opts));
}

			Supplier_Controller.prototype.addGetObject = function(){
	Supplier_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Supplier_Controller.prototype.addComplete = function(){
	Supplier_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

		