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

function RawMaterial_Controller(options){
	options = options || {};
	options.listModelClass = RawMaterial_Model;
	options.objModelClass = RawMaterial_Model;
	RawMaterial_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
	this.add_get_list_for_concrete();
	this.add_supplier_orders_list();
	this.add_update_procurement();
	this.add_oper_week_report();
	this.add_total_report();
	this.add_total_details_report();
	this.add_set_min_quant();
	this.add_correct_consumption();
	this.add_correct_obnul();
	this.add_correct_list();
	this.add_total_list();
	this.add_mat_totals();
		
}
extend(RawMaterial_Controller,ControllerObjServer);

			RawMaterial_Controller.prototype.addInsert = function(){
	RawMaterial_Controller.superclass.addInsert.call(this);
	
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
	options.alias = "Плановый приход";
	var field = new FieldFloat("planned_procurement",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дней завоза";
	var field = new FieldInt("supply_days_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("concrete_part",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("ord",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Объем ТС завоза";
	var field = new FieldInt("supply_volume",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("store_days",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("min_end_quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("max_required_quant_tolerance_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("max_fact_quant_tolerance_percent",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Цемент,учет в силосе";
	var field = new FieldBool("is_cement",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			RawMaterial_Controller.prototype.addUpdate = function(){
	RawMaterial_Controller.superclass.addUpdate.call(this);
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
	options.alias = "Плановый приход";
	var field = new FieldFloat("planned_procurement",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дней завоза";
	var field = new FieldInt("supply_days_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("concrete_part",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("ord",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Объем ТС завоза";
	var field = new FieldInt("supply_volume",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("store_days",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("min_end_quant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("max_required_quant_tolerance_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("max_fact_quant_tolerance_percent",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Цемент,учет в силосе";
	var field = new FieldBool("is_cement",options);
	
	pm.addField(field);
	
	
}

			RawMaterial_Controller.prototype.addDelete = function(){
	RawMaterial_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			RawMaterial_Controller.prototype.addGetList = function(){
	RawMaterial_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Плановый приход";
	pm.addField(new FieldFloat("planned_procurement",f_opts));
	var f_opts = {};
	f_opts.alias = "Дней завоза";
	pm.addField(new FieldInt("supply_days_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("concrete_part",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("ord",f_opts));
	var f_opts = {};
	f_opts.alias = "Объем ТС завоза";
	pm.addField(new FieldInt("supply_volume",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("store_days",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("min_end_quant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("max_required_quant_tolerance_percent",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("max_fact_quant_tolerance_percent",f_opts));
	var f_opts = {};
	f_opts.alias = "Цемент,учет в силосе";
	pm.addField(new FieldBool("is_cement",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("ord");
	
}

			RawMaterial_Controller.prototype.addGetObject = function(){
	RawMaterial_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			RawMaterial_Controller.prototype.addComplete = function(){
	RawMaterial_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

			RawMaterial_Controller.prototype.add_get_list_for_concrete = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_list_for_concrete',opts);
	
	this.addPublicMethod(pm);
}

			RawMaterial_Controller.prototype.add_supplier_orders_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('supplier_orders_list',opts);
	
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

			RawMaterial_Controller.prototype.add_update_procurement = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('update_procurement',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldText("docs",options));
	
			
	this.addPublicMethod(pm);
}

			RawMaterial_Controller.prototype.add_oper_week_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('oper_week_report',opts);
	
	this.addPublicMethod(pm);
}

			RawMaterial_Controller.prototype.add_total_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('total_report',opts);
	
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

			RawMaterial_Controller.prototype.add_total_details_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('total_details_report',opts);
	
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

			RawMaterial_Controller.prototype.add_set_min_quant = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_min_quant',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDateTime("week_day",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("material_id",options));
	
				
	
	var options = {};
	
		options.maxlength = "19";
	
		pm.addField(new FieldFloat("quant",options));
	
			
	this.addPublicMethod(pm);
}

			RawMaterial_Controller.prototype.add_correct_consumption = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('correct_consumption',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("material_id",options));
	
				
	
	var options = {};
	
		options.maxlength = "19";
	
		pm.addField(new FieldFloat("quant",options));
	
			
	this.addPublicMethod(pm);
}

			RawMaterial_Controller.prototype.add_correct_obnul = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('correct_obnul',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("material_id",options));
	
				
	
	var options = {};
	
		options.maxlength = "19";
	
		pm.addField(new FieldFloat("quant",options));
	
			
	this.addPublicMethod(pm);
}

			RawMaterial_Controller.prototype.add_correct_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('correct_list',opts);
	
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

			RawMaterial_Controller.prototype.add_total_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('total_list',opts);
	
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

			RawMaterial_Controller.prototype.add_mat_totals = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('mat_totals',opts);
	
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

		