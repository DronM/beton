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

function ProductionSite_Controller(options){
	options = options || {};
	options.listModelClass = ProductionSite_Model;
	options.objModelClass = ProductionSite_Model;
	ProductionSite_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_get_list_for_edit();
		
}
extend(ProductionSite_Controller,ControllerObjServer);

			ProductionSite_Controller.prototype.addInsert = function(){
	ProductionSite_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("elkon_connection",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Активен";
	var field = new FieldBool("active",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("last_elkon_production_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("missing_elkon_production_ids",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ProductionSite_Controller.prototype.addUpdate = function(){
	ProductionSite_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	field = new FieldString("old_name",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("elkon_connection",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Активен";
	var field = new FieldBool("active",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("last_elkon_production_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("missing_elkon_production_ids",options);
	
	pm.addField(field);
	
	
}

			ProductionSite_Controller.prototype.addDelete = function(){
	ProductionSite_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
	var options = {"required":true};
		
	pm.addField(new FieldString("name",options));
}

			ProductionSite_Controller.prototype.addGetList = function(){
	ProductionSite_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("elkon_connection",f_opts));
	var f_opts = {};
	f_opts.alias = "Активен";
	pm.addField(new FieldBool("active",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("last_elkon_production_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldArray("missing_elkon_production_ids",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

			ProductionSite_Controller.prototype.addGetObject = function(){
	ProductionSite_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldString("name",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ProductionSite_Controller.prototype.add_get_list_for_edit = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_list_for_edit',opts);
	
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

		