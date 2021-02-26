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

function LoginDevice_Controller(options){
	options = options || {};
	options.listModelClass = LoginDeviceList_Model;
	LoginDevice_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
	this.add_switch_banned();
		
}
extend(LoginDevice_Controller,ControllerObjServer);

			LoginDevice_Controller.prototype.addGetList = function(){
	LoginDevice_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldText("user_agent",f_opts));
	var f_opts = {};
	f_opts.alias = "Имя пользователя";
	pm.addField(new FieldString("user_descr",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата входа";
	pm.addField(new FieldDateTimeTZ("date_time_in",f_opts));
	var f_opts = {};
	f_opts.alias = "Вход запрещен";
	pm.addField(new FieldBool("banned",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("ban_hash",f_opts));
}

			LoginDevice_Controller.prototype.add_switch_banned = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('switch_banned',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldBool("banned",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "32";
	
		pm.addField(new FieldString("hash",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("user_id",options));
	
			
	this.addPublicMethod(pm);
}

		