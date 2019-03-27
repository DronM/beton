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

function Shift_Controller(options){
	options = options || {};
	Shift_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_get_open_shift();
	this.add_close_shift();
		
}
extend(Shift_Controller,ControllerObjServer);

			Shift_Controller.prototype.add_get_open_shift = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_open_shift',opts);
	
	this.addPublicMethod(pm);
}

			Shift_Controller.prototype.add_close_shift = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('close_shift',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date",options));
	
			
	this.addPublicMethod(pm);
}

		