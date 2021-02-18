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

function SessionVar_Controller(options){
	options = options || {};
	SessionVar_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_set_value();
	this.add_get_values();
		
}
extend(SessionVar_Controller,ControllerObjServer);

			SessionVar_Controller.prototype.add_set_value = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_value',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("val",options));
	
			
	this.addPublicMethod(pm);
}

			SessionVar_Controller.prototype.add_get_values = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_values',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("id_list",options));
	
				
	
	var options = {};
	
		options.maxlength = "1";
	
		pm.addField(new FieldString("field_sep",options));
	
			
	this.addPublicMethod(pm);
}

		