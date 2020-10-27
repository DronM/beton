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

function LabEntryDetail_Controller(options){
	options = options || {};
	options.listModelClass = LabEntryDetailList_Model;
	options.objModelClass = LabEntryDetailList_Model;
	LabEntryDetail_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(LabEntryDetail_Controller,ControllerObjServer);

			LabEntryDetail_Controller.prototype.addInsert = function(){
	LabEntryDetail_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id_key",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Код";
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Отгрузка";options.required = true;
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ОК";
	var field = new FieldInt("ok",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Масса";
	var field = new FieldInt("weight",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "КН";
	var field = new FieldInt("kn",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			LabEntryDetail_Controller.prototype.addUpdate = function(){
	LabEntryDetail_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id_key",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id_key",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Код";
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Отгрузка";
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ОК";
	var field = new FieldInt("ok",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Масса";
	var field = new FieldInt("weight",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "КН";
	var field = new FieldInt("kn",options);
	
	pm.addField(field);
	
	
}

			LabEntryDetail_Controller.prototype.addDelete = function(){
	LabEntryDetail_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id_key",options));
}

			LabEntryDetail_Controller.prototype.addGetList = function(){
	LabEntryDetail_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("id_key",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("shipment_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("code",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldDateTime("ship_date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Марка";
	pm.addField(new FieldJSON("concrete_types_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "ОК";
	pm.addField(new FieldInt("ok",f_opts));
	var f_opts = {};
	f_opts.alias = "Масса";
	pm.addField(new FieldInt("weight",f_opts));
	var f_opts = {};
	f_opts.alias = "П7%";
	pm.addField(new FieldInt("p7",f_opts));
	var f_opts = {};
	f_opts.alias = "П28%";
	pm.addField(new FieldInt("p28",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldDate("p_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("kn",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("mpa",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("mpa_avg",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("pres_norm",f_opts));
}

			LabEntryDetail_Controller.prototype.addGetObject = function(){
	LabEntryDetail_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id_key",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		