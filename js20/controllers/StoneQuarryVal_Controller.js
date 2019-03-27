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

function StoneQuarryVal_Controller(options){
	options = options || {};
	options.listModelClass = StoneQuarryValList_Model;
	options.objModelClass = StoneQuarryValList_Model;
	StoneQuarryVal_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(StoneQuarryVal_Controller,ControllerObjServer);

			StoneQuarryVal_Controller.prototype.addInsert = function(){
	StoneQuarryVal_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("day",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("quarry_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_nasip",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_istin",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_dust",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_humid",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_void",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("v_comment",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			StoneQuarryVal_Controller.prototype.addUpdate = function(){
	StoneQuarryVal_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("day",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("quarry_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_nasip",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_istin",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_dust",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_humid",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("v_void",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("v_comment",options);
	
	pm.addField(field);
	
	
}

			StoneQuarryVal_Controller.prototype.addDelete = function(){
	StoneQuarryVal_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			StoneQuarryVal_Controller.prototype.addGetList = function(){
	StoneQuarryVal_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDate("day",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("day_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("quarry_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("quarry_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("v_nasip",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("v_istin",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("v_dust",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("v_humid",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("v_void",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("v_comment",f_opts));
}

			StoneQuarryVal_Controller.prototype.addGetObject = function(){
	StoneQuarryVal_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		