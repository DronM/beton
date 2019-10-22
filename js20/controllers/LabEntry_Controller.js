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

function LabEntry_Controller(options){
	options = options || {};
	options.listModelClass = LabEntryList_Model;
	options.objModelClass = LabEntryList_Model;
	LabEntry_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_lab_report();
	this.add_item_report();
	this.add_lab_avg_report();
	this.add_item_on_rate_period_report();
	this.add_lab_entry30_days();
	this.add_lab_vehicle_list();
	this.add_lab_orders_list();
		
}
extend(LabEntry_Controller,ControllerObjServer);

			LabEntry_Controller.prototype.addInsert = function(){
	LabEntry_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Отгрузка";options.primaryKey = true;options.required = true;
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Подборы";
	var field = new FieldText("samples",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материалы";
	var field = new FieldText("materials",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "OK2";
	var field = new FieldText("ok2",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время";
	var field = new FieldText("time",options);
	
	pm.addField(field);
	
	
}

			LabEntry_Controller.prototype.addUpdate = function(){
	LabEntry_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Отгрузка";options.primaryKey = true;
	var field = new FieldInt("shipment_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_shipment_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Подборы";
	var field = new FieldText("samples",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материалы";
	var field = new FieldText("materials",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "OK2";
	var field = new FieldText("ok2",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время";
	var field = new FieldText("time",options);
	
	pm.addField(field);
	
	
}

			LabEntry_Controller.prototype.addDelete = function(){
	LabEntry_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Отгрузка";	
	pm.addField(new FieldInt("shipment_id",options));
}

			LabEntry_Controller.prototype.addGetList = function(){
	LabEntry_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("shipment_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Завод";
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Марка";
	pm.addField(new FieldJSON("concrete_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("concrete_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("ok",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("weight",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("p7",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("p28",f_opts));
	var f_opts = {};
	f_opts.alias = "Подборы";
	pm.addField(new FieldText("samples",f_opts));
	var f_opts = {};
	f_opts.alias = "Материалы";
	pm.addField(new FieldText("materials",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Заказчик";
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("client_phone",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("destination_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Объект";
	pm.addField(new FieldJSON("destinations_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "ОК2";
	pm.addField(new FieldText("ok2",f_opts));
	var f_opts = {};
	f_opts.alias = "Время";
	pm.addField(new FieldText("time",f_opts));
}

			LabEntry_Controller.prototype.addGetObject = function(){
	LabEntry_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("shipment_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			LabEntry_Controller.prototype.add_lab_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('lab_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

			LabEntry_Controller.prototype.add_item_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('item_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

			LabEntry_Controller.prototype.add_lab_avg_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('lab_avg_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

			LabEntry_Controller.prototype.add_item_on_rate_period_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('item_on_rate_period_report',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

			LabEntry_Controller.prototype.add_lab_entry30_days = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('lab_entry30_days',opts);
	
	this.addPublicMethod(pm);
}

			LabEntry_Controller.prototype.add_lab_vehicle_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('lab_vehicle_list',opts);
	
	this.addPublicMethod(pm);
}

			LabEntry_Controller.prototype.add_lab_orders_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('lab_orders_list',opts);
	
	this.addPublicMethod(pm);
}

		