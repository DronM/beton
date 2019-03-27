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

function Graph_Controller(options){
	options = options || {};
	Graph_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_get_plant_load();
	this.add_make_plant_load();
	this.add_clear_cache();
		
}
extend(Graph_Controller,ControllerObjServer);

			Graph_Controller.prototype.add_get_plant_load = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_plant_load',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_time_from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_time_to",options));
	
			
	this.addPublicMethod(pm);
}

			Graph_Controller.prototype.add_make_plant_load = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('make_plant_load',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_time_from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_time_to",options));
	
			
	this.addPublicMethod(pm);
}

			Graph_Controller.prototype.add_clear_cache = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('clear_cache',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_time_from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_time_to",options));
	
			
	this.addPublicMethod(pm);
}

		