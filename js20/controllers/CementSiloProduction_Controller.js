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

function CementSiloProduction_Controller(options){
	options = options || {};
	options.listModelClass = CementSiloProductionList_Model;
	options.objModelClass = CementSiloProductionList_Model;
	CementSiloProduction_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(CementSiloProduction_Controller,ControllerObjServer);

			CementSiloProduction_Controller.prototype.addInsert = function(){
	CementSiloProduction_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("cement_silo_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTimeTZ("production_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("production_vehicle_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'shift,free,assigned,busy,left_for_dest,at_dest,left_for_base,out_from_shift,out,shift_added';
	var field = new FieldEnum("vehicle_state",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			CementSiloProduction_Controller.prototype.addUpdate = function(){
	CementSiloProduction_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cement_silo_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	field = new FieldDateTimeTZ("old_date_time",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("production_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("production_vehicle_descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("vehicle_id",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'shift,free,assigned,busy,left_for_dest,at_dest,left_for_base,out_from_shift,out,shift_added';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("vehicle_state",options);
	
	pm.addField(field);
	
	
}

			CementSiloProduction_Controller.prototype.addDelete = function(){
	CementSiloProduction_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
	var options = {"required":true};
		
	pm.addField(new FieldDateTimeTZ("date_time",options));
}

			CementSiloProduction_Controller.prototype.addGetList = function(){
	CementSiloProduction_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSON("cement_silos_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("production_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("production_vehicle_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("vehicles_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("vehicle_state",f_opts));
}

			CementSiloProduction_Controller.prototype.addGetObject = function(){
	CementSiloProduction_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		