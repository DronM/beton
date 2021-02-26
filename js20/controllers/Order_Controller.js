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

function Order_Controller(options){
	options = options || {};
	options.listModelClass = OrderList_Model;
	options.objModelClass = OrderDialog_Model;
	Order_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_get_make_orders_form();
	this.add_get_make_orders_form_ord();
	this.add_get_make_orders_form_veh();
	this.add_get_make_orders_form_mat();
	this.add_get_make_orders_for_lab_form();
	this.add_get_make_orders_for_lab_form_ord();
	this.add_get_make_orders_for_lab_form_veh();
	this.add_get_make_orders_for_lab_form_mat();
	this.add_get_make_orders_list();
	this.add_get_make_orders_for_lab_list();
	this.add_get_avail_spots();
	this.add_complete_descr();
	this.add_get_comment();
	this.add_fields_from_client_order();
	this.add_set_payed();
	this.addComplete();
	this.add_get_list_for_client();
		
}
extend(Order_Controller,ControllerObjServer);

			Order_Controller.prototype.addInsert = function(){
	Order_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "клиент";options.required = true;
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Направление";options.required = true;
	var field = new FieldInt("destination_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Марка бетона";options.required = true;
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Прокачка";	
	options.enumValues = 'pump,band,none';
	var field = new FieldEnum("unload_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Описание";
	var field = new FieldText("descr",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";options.required = true;
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время до";
	var field = new FieldDateTime("date_time_to",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Количество";
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Сот.телефон";
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Разгрузка куб/ч";
	var field = new FieldFloat("unload_speed",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автор";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Язык";
	var field = new FieldInt("lang_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Сумма";
	var field = new FieldFloat("total",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость";
	var field = new FieldFloat("concrete_price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость дост.";
	var field = new FieldFloat("destination_price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость прокачки";
	var field = new FieldFloat("unload_price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Насос";
	var field = new FieldInt("pump_vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Оплата на месте";
	var field = new FieldBool("pay_cash",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("total_edit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("payed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("under_control",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Кто последний вносил изменения";
	var field = new FieldInt("last_modif_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время последнего изменения";
	var field = new FieldDateTimeTZ("last_modif_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время создания";
	var field = new FieldDateTimeTZ("create_date_time",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Order_Controller.prototype.addUpdate = function(){
	Order_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "клиент";
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Направление";
	var field = new FieldInt("destination_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Марка бетона";
	var field = new FieldInt("concrete_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Прокачка";	
	options.enumValues = 'pump,band,none';
	
	var field = new FieldEnum("unload_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Описание";
	var field = new FieldText("descr",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время до";
	var field = new FieldDateTime("date_time_to",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Количество";
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Сот.телефон";
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Разгрузка куб/ч";
	var field = new FieldFloat("unload_speed",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автор";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Язык";
	var field = new FieldInt("lang_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Сумма";
	var field = new FieldFloat("total",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость";
	var field = new FieldFloat("concrete_price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость дост.";
	var field = new FieldFloat("destination_price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость прокачки";
	var field = new FieldFloat("unload_price",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Насос";
	var field = new FieldInt("pump_vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Оплата на месте";
	var field = new FieldBool("pay_cash",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("total_edit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("payed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("under_control",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Кто последний вносил изменения";
	var field = new FieldInt("last_modif_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время последнего изменения";
	var field = new FieldDateTimeTZ("last_modif_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время создания";
	var field = new FieldDateTimeTZ("create_date_time",options);
	
	pm.addField(field);
	
	
}

			Order_Controller.prototype.addDelete = function(){
	Order_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Order_Controller.prototype.addGetList = function(){
	Order_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Номер";
	pm.addField(new FieldString("number",f_opts));
	var f_opts = {};
	f_opts.alias = "Клиент";
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
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
	f_opts.alias = "Вид разгрузки";
	pm.addField(new FieldString("unload_type",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	f_opts.alias = "Прораб";
	pm.addField(new FieldText("descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("phone_cel",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Количество";
	pm.addField(new FieldFloat("quant",f_opts));
	var f_opts = {};
	f_opts.alias = "Сотрудник";
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("orders_ref",f_opts));
}

			Order_Controller.prototype.addGetObject = function(){
	Order_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Order_Controller.prototype.add_get_make_orders_form = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_form',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_form_ord = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_form_ord',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_form_veh = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_form_veh',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_form_mat = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_form_mat',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_for_lab_form = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_for_lab_form',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_for_lab_form_ord = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_for_lab_form_ord',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_for_lab_form_veh = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_for_lab_form_veh',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_for_lab_form_mat = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_for_lab_form_mat',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_list',opts);
	
				
					
					
				
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_make_orders_for_lab_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_make_orders_for_lab_list',opts);
	
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_avail_spots = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_avail_spots',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldDate("date",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldFloat("quant",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldFloat("speed",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_complete_descr = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_descr',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("client_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("descr",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_get_comment = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_comment',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("order_id",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_fields_from_client_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('fields_from_client_order',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("client_order_id",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.add_set_payed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_payed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Order_Controller.prototype.addComplete = function(){
	Order_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("number",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("number");	
}

			Order_Controller.prototype.add_get_list_for_client = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_list_for_client',opts);
	
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

		