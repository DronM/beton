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

function MaterialFactConsumptionCorretion_Controller(options){
	options = options || {};
	options.listModelClass = MaterialFactConsumptionCorretionList_Model;
	options.objModelClass = MaterialFactConsumptionCorretionList_Model;
	MaterialFactConsumptionCorretion_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_operator_insert_correction();
		
}
extend(MaterialFactConsumptionCorretion_Controller,ControllerObjServer);

			MaterialFactConsumptionCorretion_Controller.prototype.addInsert = function(){
	MaterialFactConsumptionCorretion_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTimeTZ("date_time_set",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cement_silo_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("elkon_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			MaterialFactConsumptionCorretion_Controller.prototype.addUpdate = function(){
	MaterialFactConsumptionCorretion_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time_set",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cement_silo_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("elkon_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			MaterialFactConsumptionCorretion_Controller.prototype.addDelete = function(){
	MaterialFactConsumptionCorretion_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			MaterialFactConsumptionCorretion_Controller.prototype.addGetList = function(){
	MaterialFactConsumptionCorretion_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Завод";
	pm.addField(new FieldJSON("production_sites_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата";
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата внесения";
	pm.addField(new FieldDateTimeTZ("date_time_set",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Пользователь";
	pm.addField(new FieldJSON("users_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("material_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Материал";
	pm.addField(new FieldJSON("materials_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("cement_silo_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Силос";
	pm.addField(new FieldJSON("cement_silos_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Производство Elkon";
	pm.addField(new FieldInt("production_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Номер записи Elkon";
	pm.addField(new FieldInt("elkon_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Количество";
	pm.addField(new FieldFloat("quant",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment_text",f_opts));
}

			MaterialFactConsumptionCorretion_Controller.prototype.addGetObject = function(){
	MaterialFactConsumptionCorretion_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			MaterialFactConsumptionCorretion_Controller.prototype.add_operator_insert_correction = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('operator_insert_correction',opts);
	
				
	/*
	 Упрощенный ввод,НО через идентификатор строки фактического расхода вводить нельзя!!! т.к. у нас агрегированные данные, потому через ключи!!!
	*/

				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("production_site_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("production_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("material_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("cement_silo_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "19";
	
		pm.addField(new FieldFloat("cor_quant",options));
	
				
	
	var options = {};
	
		options.maxlength = "500";
	
		pm.addField(new FieldString("comment_text",options));
	
			
	this.addPublicMethod(pm);
}

		