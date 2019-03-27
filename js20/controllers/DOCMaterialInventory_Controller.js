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

function DOCMaterialInventory_Controller(options){
	options = options || {};
	options.listModelClass = DOCMaterialInventoryList_Model;
	options.objModelClass = DOCMaterialInventoryList_Model;
	DOCMaterialInventory_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_before_open();
	this.add_get_actions();
	this.add_get_print();
	this.add_get_details();
		
}
extend(DOCMaterialInventory_Controller,ControllerObjServer);

			DOCMaterialInventory_Controller.prototype.addInsert = function(){
	DOCMaterialInventory_Controller.superclass.addInsert.call(this);
	
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
	var field = new FieldInt("number",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Проведен";
	var field = new FieldBool("processed",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DOCMaterialInventory_Controller.prototype.addUpdate = function(){
	DOCMaterialInventory_Controller.superclass.addUpdate.call(this);
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
	var field = new FieldInt("number",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Проведен";
	var field = new FieldBool("processed",options);
	
	pm.addField(field);
	
	
}

			DOCMaterialInventory_Controller.prototype.addDelete = function(){
	DOCMaterialInventory_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DOCMaterialInventory_Controller.prototype.addGetList = function(){
	DOCMaterialInventory_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("date_time_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("processed",f_opts));
}

			DOCMaterialInventory_Controller.prototype.addGetObject = function(){
	DOCMaterialInventory_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			DOCMaterialInventory_Controller.prototype.add_before_open = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('before_open',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DOCMaterialInventory_Controller.prototype.add_get_actions = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_actions',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DOCMaterialInventory_Controller.prototype.add_get_print = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_print',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DOCMaterialInventory_Controller.prototype.add_get_details = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_details',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("cond_fields",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("cond_vals",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("cond_sgns",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("cond_ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("count",options));
	
			
	this.addPublicMethod(pm);
}

		