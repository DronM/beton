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

function LabData_Controller(options){
	options = options || {};
	options.listModelClass = LabDataList_Model;
	options.objModelClass = LabDataList_Model;
	LabData_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(LabData_Controller,ControllerObjServer);

			LabData_Controller.prototype.addInsert = function(){
	LabData_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Отгрузка";options.primaryKey = true;options.required = true;
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "ОК см";
	var field = new FieldFloat("ok_sm",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "масса";
	var field = new FieldFloat("weight",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "масса норм";
	var field = new FieldFloat("weight_norm",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "%";
	var field = new FieldFloat("percent_1",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p1";
	var field = new FieldFloat("p_1",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p2";
	var field = new FieldFloat("p_2",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p3";
	var field = new FieldFloat("p_3",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p4";
	var field = new FieldFloat("p_4",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p7";
	var field = new FieldFloat("p_7",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p28";
	var field = new FieldFloat("p_28",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p_norm";
	var field = new FieldFloat("p_norm",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "percent_2";
	var field = new FieldFloat("percent_2",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("lab_comment",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "№";
	var field = new FieldText("num",options);
	
	pm.addField(field);
	
	
}

			LabData_Controller.prototype.addUpdate = function(){
	LabData_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Отгрузка";options.primaryKey = true;
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_shipment_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "ОК см";
	var field = new FieldFloat("ok_sm",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "масса";
	var field = new FieldFloat("weight",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "масса норм";
	var field = new FieldFloat("weight_norm",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "%";
	var field = new FieldFloat("percent_1",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p1";
	var field = new FieldFloat("p_1",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p2";
	var field = new FieldFloat("p_2",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p3";
	var field = new FieldFloat("p_3",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p4";
	var field = new FieldFloat("p_4",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p7";
	var field = new FieldFloat("p_7",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p28";
	var field = new FieldFloat("p_28",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "p_norm";
	var field = new FieldFloat("p_norm",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "percent_2";
	var field = new FieldFloat("percent_2",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("lab_comment",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "№";
	var field = new FieldText("num",options);
	
	pm.addField(field);
	
	
}

			LabData_Controller.prototype.addDelete = function(){
	LabData_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Отгрузка";	
	pm.addField(new FieldInt("shipment_id",options));
}

			LabData_Controller.prototype.addGetList = function(){
	LabData_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("shipment_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldString("ship_date_time_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Заказчик";
	pm.addField(new FieldString("client_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("client_phone",f_opts));
	var f_opts = {};
	f_opts.alias = "Объект";
	pm.addField(new FieldString("destination_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Марка";
	pm.addField(new FieldString("concrete_type_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Кол-во";
	pm.addField(new FieldString("quant_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "№";
	pm.addField(new FieldString("num",f_opts));
	var f_opts = {};
	f_opts.alias = "Водитель";
	pm.addField(new FieldString("driver_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "ОК см";
	pm.addField(new FieldFloat("ok_sm",f_opts));
	var f_opts = {};
	f_opts.alias = "масса";
	pm.addField(new FieldFloat("weight",f_opts));
	var f_opts = {};
	f_opts.alias = "масса норм";
	pm.addField(new FieldFloat("weight_norm",f_opts));
	var f_opts = {};
	f_opts.alias = "%";
	pm.addField(new FieldFloat("percent_1",f_opts));
	var f_opts = {};
	f_opts.alias = "p1";
	pm.addField(new FieldFloat("p_1",f_opts));
	var f_opts = {};
	f_opts.alias = "p2";
	pm.addField(new FieldFloat("p_2",f_opts));
	var f_opts = {};
	f_opts.alias = "p3";
	pm.addField(new FieldFloat("p_3",f_opts));
	var f_opts = {};
	f_opts.alias = "p4";
	pm.addField(new FieldFloat("p_4",f_opts));
	var f_opts = {};
	f_opts.alias = "p7";
	pm.addField(new FieldFloat("p_7",f_opts));
	var f_opts = {};
	f_opts.alias = "p_norm";
	pm.addField(new FieldFloat("p_norm",f_opts));
	var f_opts = {};
	f_opts.alias = "percent_2";
	pm.addField(new FieldFloat("percent_2",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("lab_comment",f_opts));
}

			LabData_Controller.prototype.addGetObject = function(){
	LabData_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("shipment_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		