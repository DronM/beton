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

function Shipment_Controller(options){
	options = options || {};
	options.listModelClass = ShipmentList_Model;
	options.objModelClass = ShipmentDialog_Model;
	Shipment_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.add_get_list_for_order();
	this.add_get_pump_list();
	this.add_get_shipment_date_list();
	this.addGetObject();
	this.add_get_assigned_vehicle_list();
	this.add_get_operator_list();
	this.add_set_shipped();
	this.add_unset_shipped();
	this.add_shipment_report();
	this.add_shipment_invoice();
	this.add_get_time_list();
	this.add_set_blanks_exist();
	this.add_delete_shipped();
	this.add_delete_assigned();
	this.add_owner_set_agreed();
	this.add_owner_set_pump_agreed();
		
}
extend(Shipment_Controller,ControllerObjServer);

			Shipment_Controller.prototype.addInsert = function(){
	Shipment_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Заявка";options.required = true;
	var field = new FieldInt("order_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Экипаж";options.required = true;
	var field = new FieldInt("vehicle_schedule_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Количество";
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автор";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Завод";
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Баллы";
	var field = new FieldInt("client_mark",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Простой";
	var field = new FieldInterval("demurrage",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наличие бланков";
	var field = new FieldBool("blanks_exist",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("owner_agreed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("owner_agreed_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("acc_comment",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("owner_pump_agreed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("owner_pump_agreed_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("pump_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("pump_cost_edit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("ship_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("ship_cost_edit",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Shipment_Controller.prototype.addUpdate = function(){
	Shipment_Controller.superclass.addUpdate.call(this);
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
	options.alias = "Заявка";
	var field = new FieldInt("order_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Экипаж";
	var field = new FieldInt("vehicle_schedule_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Количество";
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автор";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Завод";
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Баллы";
	var field = new FieldInt("client_mark",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Простой";
	var field = new FieldInterval("demurrage",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наличие бланков";
	var field = new FieldBool("blanks_exist",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("owner_agreed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("owner_agreed_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("acc_comment",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("owner_pump_agreed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("owner_pump_agreed_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("pump_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("pump_cost_edit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("ship_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("ship_cost_edit",options);
	
	pm.addField(field);
	
	
}

			Shipment_Controller.prototype.addDelete = function(){
	Shipment_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			Shipment_Controller.prototype.addGetList = function(){
	Shipment_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Номер";
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата отгрузки";
	pm.addField(new FieldDateTime("ship_date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Завод";
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Клиент";
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Объект";
	pm.addField(new FieldJSON("destinations_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("destination_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Марка";
	pm.addField(new FieldJSON("concrete_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("concrete_type_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Количество";
	pm.addField(new FieldFloat("quant",f_opts));
	var f_opts = {};
	f_opts.alias = "Автомобиль";
	pm.addField(new FieldJSON("vehicles_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Водитель";
	pm.addField(new FieldJSON("drivers_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("driver_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("vehicle_owner_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Владелец";
	pm.addField(new FieldJSON("vehicle_owners_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий бухгалетрии";
	pm.addField(new FieldText("acc_comment",f_opts));
	var f_opts = {};
	f_opts.alias = "Простой";
	pm.addField(new FieldString("demurrage",f_opts));
	var f_opts = {};
	f_opts.alias = "Стоимость доставки";
	pm.addField(new FieldFloat("cost",f_opts));
	var f_opts = {};
	f_opts.alias = "Стомость простоя";
	pm.addField(new FieldFloat("demurrage_cost",f_opts));
	var f_opts = {};
	f_opts.alias = "Стоимость насос";
	pm.addField(new FieldFloat("pump_cost",f_opts));
	var f_opts = {};
	f_opts.alias = "Насос";
	pm.addField(new FieldJSON("pump_vehicles_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "TRUE";
	pm.addField(new FieldInt("pump_vehicle_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Насос,владелец";
	pm.addField(new FieldJSON("pump_vehicle_owners_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "TRUE";
	pm.addField(new FieldInt("pump_vehicle_owner_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("shipped",f_opts));
	var f_opts = {};
	f_opts.alias = "Оценка";
	pm.addField(new FieldInt("client_mark",f_opts));
	var f_opts = {};
	f_opts.alias = "Наличие бланков";
	pm.addField(new FieldBool("blanks_exist",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Автор";
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Согласовано миксер";
	pm.addField(new FieldBool("owner_agreed",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата согласования миксер";
	pm.addField(new FieldDateTimeTZ("owner_agreed_date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Согласовано насос";
	pm.addField(new FieldBool("owner_pump_agreed",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата согласования насос";
	pm.addField(new FieldDateTimeTZ("owner_pump_agreed_date_time",f_opts));
}

			Shipment_Controller.prototype.add_get_list_for_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_list_for_order',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_get_pump_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_pump_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_get_shipment_date_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_shipment_date_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.addGetObject = function(){
	Shipment_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Shipment_Controller.prototype.add_get_assigned_vehicle_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_assigned_vehicle_list',opts);
	
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_get_operator_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_operator_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_set_shipped = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_shipped',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_unset_shipped = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('unset_shipped',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_shipment_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('shipment_report',opts);
	
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
	
		pm.addField(new FieldString("grp_fields",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("agg_fields",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_shipment_invoice = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('shipment_invoice',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_get_time_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_time_list',opts);
	
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

			Shipment_Controller.prototype.add_set_blanks_exist = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_blanks_exist',opts);
	
				
	
	var options = {};
	
		options.maxlength = "13";
	
		pm.addField(new FieldString("barcode",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_delete_shipped = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_shipped',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("shipment_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "500";
	
		pm.addField(new FieldString("comment_text",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_delete_assigned = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_assigned',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("shipment_id",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_owner_set_agreed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('owner_set_agreed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("shipment_id",options));
	
			
	this.addPublicMethod(pm);
}

			Shipment_Controller.prototype.add_owner_set_pump_agreed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('owner_set_pump_agreed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("shipment_id",options));
	
			
	this.addPublicMethod(pm);
}

		