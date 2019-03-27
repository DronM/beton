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

function OrderFromClient_Controller(options){
	options = options || {};
	options.listModelClass = OrderFromClientList_Model;
	OrderFromClient_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addDelete();
	this.addGetList();
	this.add_set_viewed();
		
}
extend(OrderFromClient_Controller,ControllerObjServer);

			OrderFromClient_Controller.prototype.addDelete = function(){
	OrderFromClient_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			OrderFromClient_Controller.prototype.addGetList = function(){
	OrderFromClient_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Дата";
	pm.addField(new FieldString("date_time_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Клиент";
	pm.addField(new FieldText("name",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("tel",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("tel_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Марка";
	pm.addField(new FieldString("concrete_type",f_opts));
	var f_opts = {};
	f_opts.alias = "Объект";
	pm.addField(new FieldText("dest",f_opts));
	var f_opts = {};
	f_opts.alias = "Сумма";
	pm.addField(new FieldFloat("total",f_opts));
	var f_opts = {};
	f_opts.alias = "Сумма";
	pm.addField(new FieldString("total_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Количество";
	pm.addField(new FieldFloat("quant",f_opts));
	var f_opts = {};
	f_opts.alias = "Есть насос";
	pm.addField(new FieldBool("pump",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment_text",f_opts));
}

			OrderFromClient_Controller.prototype.add_set_viewed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_viewed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

		