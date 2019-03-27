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

function DOCMaterialProcurement_Controller(options){
	options = options || {};
	options.listModelClass = DOCMaterialProcurementList_Model;
	options.objModelClass = DOCMaterialProcurementList_Model;
	DOCMaterialProcurement_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_before_open();
	this.add_get_actions();
	this.add_get_print();
	this.add_get_material_list();
	this.add_get_shift_list();
		
}
extend(DOCMaterialProcurement_Controller,ControllerObjServer);

			DOCMaterialProcurement_Controller.prototype.addInsert = function(){
	DOCMaterialProcurement_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";options.required = true;
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер";
	var field = new FieldString("number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("doc_ref",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Проведен";
	var field = new FieldBool("processed",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автор";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Поставщик";options.required = true;
	var field = new FieldInt("supplier_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Перевозчик";options.required = true;
	var field = new FieldInt("carrier_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Водитель";
	var field = new FieldString("driver",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "гос.номер";
	var field = new FieldString("vehicle_plate",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материал";options.required = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Брутто";
	var field = new FieldFloat("quant_gross",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Нетто";
	var field = new FieldFloat("quant_net",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DOCMaterialProcurement_Controller.prototype.addUpdate = function(){
	DOCMaterialProcurement_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата";
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Номер";
	var field = new FieldString("number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("doc_ref",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Проведен";
	var field = new FieldBool("processed",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Автор";
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Поставщик";
	var field = new FieldInt("supplier_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Перевозчик";
	var field = new FieldInt("carrier_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Водитель";
	var field = new FieldString("driver",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "гос.номер";
	var field = new FieldString("vehicle_plate",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Материал";
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Брутто";
	var field = new FieldFloat("quant_gross",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Нетто";
	var field = new FieldFloat("quant_net",options);
	
	pm.addField(field);
	
	
}

			DOCMaterialProcurement_Controller.prototype.addDelete = function(){
	DOCMaterialProcurement_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DOCMaterialProcurement_Controller.prototype.addGetList = function(){
	DOCMaterialProcurement_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("processed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("supplier_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("suppliers_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("carrier_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("carriers_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("driver",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("vehicle_plate",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("material_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("materials_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("quant_gross",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("quant_net",f_opts));
}

			DOCMaterialProcurement_Controller.prototype.addGetObject = function(){
	DOCMaterialProcurement_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			DOCMaterialProcurement_Controller.prototype.add_before_open = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('before_open',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DOCMaterialProcurement_Controller.prototype.add_get_actions = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_actions',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DOCMaterialProcurement_Controller.prototype.add_get_print = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_print',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DOCMaterialProcurement_Controller.prototype.add_get_material_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_material_list',opts);
	
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

			DOCMaterialProcurement_Controller.prototype.add_get_shift_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_shift_list',opts);
	
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

		