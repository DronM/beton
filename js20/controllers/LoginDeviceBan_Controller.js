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

function LoginDeviceBan_Controller(options){
	options = options || {};
	options.listModelClass = LoginDeviceBan_Model;
	options.objModelClass = LoginDeviceBan_Model;
	LoginDeviceBan_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(LoginDeviceBan_Controller,ControllerObjServer);

			LoginDeviceBan_Controller.prototype.addInsert = function(){
	LoginDeviceBan_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("hash",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	
}

			LoginDeviceBan_Controller.prototype.addDelete = function(){
	LoginDeviceBan_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("user_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldString("hash",options));
}

			LoginDeviceBan_Controller.prototype.addGetList = function(){
	LoginDeviceBan_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("hash",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата создания";
	pm.addField(new FieldDateTimeTZ("create_dt",f_opts));
}

			LoginDeviceBan_Controller.prototype.addGetObject = function(){
	LoginDeviceBan_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldString("hash",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		