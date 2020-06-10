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

function Client_Controller(options){
	options = options || {};
	options.listModelClass = ClientList_Model;
	options.objModelClass = ClientDialog_Model;
	Client_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
	this.add_complete_for_order();
	this.add_union();
	this.add_set_duplicate_valid();
	this.add_get_duplicates_list();
	this.add_insert_from_order();
		
}
extend(Client_Controller,ControllerObjServer);

			Client_Controller.prototype.addInsert = function(){
	Client_Controller.superclass.addInsert.call(this);
	
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
	options.alias = "Полное наименование";
	var field = new FieldText("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Сотовый телефон";
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("manager_comment",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид контрагента";
	var field = new FieldInt("client_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Тип контрагента";	
	options.enumValues = 'buyer,acc,else';
	var field = new FieldEnum("client_kind",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Источник обращения";
	var field = new FieldInt("client_come_from_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Менеджер";
	var field = new FieldInt("manager_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("create_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("email",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("inn",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Аккаунт";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата начала выборки данных";
	var field = new FieldDate("account_from_date",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Client_Controller.prototype.addUpdate = function(){
	Client_Controller.superclass.addUpdate.call(this);
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
	options.alias = "Сотовый телефон";
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("manager_comment",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид контрагента";
	var field = new FieldInt("client_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Тип контрагента";	
	options.enumValues = 'buyer,acc,else';
	
	var field = new FieldEnum("client_kind",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Источник обращения";
	var field = new FieldInt("client_come_from_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Менеджер";
	var field = new FieldInt("manager_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("create_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("email",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("inn",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Аккаунт";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата начала выборки данных";
	var field = new FieldDate("account_from_date",options);
	
	pm.addField(field);
	
	
}

			Client_Controller.prototype.addDelete = function(){
	Client_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			Client_Controller.prototype.addGetList = function(){
	Client_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Наименование";
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("phone_cel",f_opts));
	var f_opts = {};
	f_opts.alias = "Объем";
	pm.addField(new FieldString("quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("client_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_type_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Источник";
	pm.addField(new FieldJSON("client_come_from_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_come_from_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Вид клиента";
	pm.addField(new FieldString("client_kind",f_opts));
	var f_opts = {};
	f_opts.alias = "Наш";
	pm.addField(new FieldString("ours",f_opts));
	var f_opts = {};
	f_opts.alias = "Первое обращение";
	pm.addField(new FieldDate("first_call_date",f_opts));
	var f_opts = {};
	f_opts.alias = "Кто завел";
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "ИНН";
	pm.addField(new FieldString("inn",f_opts));
	var f_opts = {};
	f_opts.alias = "Аккаунт";
	pm.addField(new FieldJSON("accounts_ref",f_opts));
}

			Client_Controller.prototype.addGetObject = function(){
	Client_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Client_Controller.prototype.addComplete = function(){
	Client_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

			Client_Controller.prototype.add_complete_for_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_for_order',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("name",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Client_Controller.prototype.add_union = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('union',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("main_client_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("client_ids",options));
	
			
	this.addPublicMethod(pm);
}

			Client_Controller.prototype.add_set_duplicate_valid = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_duplicate_valid',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("tel",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("client_ids",options));
	
			
	this.addPublicMethod(pm);
}

			Client_Controller.prototype.add_get_duplicates_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_duplicates_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("count",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("ord_fields",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("ord_directs",options));
	
			
	this.addPublicMethod(pm);
}

			Client_Controller.prototype.add_insert_from_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('insert_from_order',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("name",options));
	
			
	this.addPublicMethod(pm);
}

		