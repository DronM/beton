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

function ProductionComment_Controller(options){
	options = options || {};
	options.listModelClass = ProductionComment_Model;
	options.objModelClass = ProductionComment_Model;
	ProductionComment_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ProductionComment_Controller,ControllerObjServer);

			ProductionComment_Controller.prototype.addInsert = function(){
	ProductionComment_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	
}

			ProductionComment_Controller.prototype.addUpdate = function(){
	ProductionComment_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("production_site_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_production_site_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("production_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_production_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("material_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_material_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	
}

			ProductionComment_Controller.prototype.addDelete = function(){
	ProductionComment_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("production_site_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("production_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldInt("material_id",options));
}

			ProductionComment_Controller.prototype.addGetList = function(){
	ProductionComment_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("production_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("material_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
}

			ProductionComment_Controller.prototype.addGetObject = function(){
	ProductionComment_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("production_site_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldInt("production_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldInt("material_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		