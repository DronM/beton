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

function Caller_Controller(options){
	options = options || {};
	Caller_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_call();
		
}
extend(Caller_Controller,ControllerObjServer);

			Caller_Controller.prototype.add_call = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('call',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "15";
	
		pm.addField(new FieldString("tel",options));
	
			
	this.addPublicMethod(pm);
}

		