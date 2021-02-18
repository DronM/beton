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

function Destination_Controller(options){
	options = options || {};
	options.listModelClass = DestinationList_Model;
	options.objModelClass = DestinationDialog_Model;
	Destination_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_complete_dest();
	this.add_complete_for_order();
	this.add_get_data_for_new_address();
	this.add_get_for_client_list();
	this.add_get_coords_on_name();
	this.add_get_route_to_zone();
	this.add_at_dest_avg_time();
	this.add_route_to_dest_avg_time();
		
}
extend(Destination_Controller,ControllerObjServer);

			Destination_Controller.prototype.addInsert = function(){
	Destination_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";options.required = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Расстояние";
	var field = new FieldFloat("distance",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время";options.required = true;
	var field = new FieldTime("time_route",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость";
	var field = new FieldFloat("price",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("zone",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("special_price",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("price_for_driver",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("near_road_lon",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("near_road_lat",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Destination_Controller.prototype.addUpdate = function(){
	Destination_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Расстояние";
	var field = new FieldFloat("distance",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Время";
	var field = new FieldTime("time_route",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Стоимость";
	var field = new FieldFloat("price",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("zone",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("special_price",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("price_for_driver",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("near_road_lon",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("near_road_lat",options);
	
	pm.addField(field);
	
	
}

			Destination_Controller.prototype.addDelete = function(){
	Destination_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			Destination_Controller.prototype.addGetList = function(){
	Destination_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("distance",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldTime("time_route",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("special_price",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("price",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("price_for_driver",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

			Destination_Controller.prototype.addGetObject = function(){
	Destination_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Destination_Controller.prototype.add_complete_dest = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_dest',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("name_pat",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("client_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Destination_Controller.prototype.add_complete_for_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_for_order',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("name_pat",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("client_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Destination_Controller.prototype.add_get_data_for_new_address = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_data_for_new_address',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("address_str",options));
	
			
	this.addPublicMethod(pm);
}

			Destination_Controller.prototype.add_get_for_client_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_for_client_list',opts);
	
	this.addPublicMethod(pm);
}

			Destination_Controller.prototype.add_get_coords_on_name = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_coords_on_name',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("name",options));
	
			
	this.addPublicMethod(pm);
}

			Destination_Controller.prototype.add_get_route_to_zone = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_route_to_zone',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("zone_coords",options));
	
			
	this.addPublicMethod(pm);
}

			Destination_Controller.prototype.add_at_dest_avg_time = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('at_dest_avg_time',opts);
	
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

			Destination_Controller.prototype.add_route_to_dest_avg_time = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('route_to_dest_avg_time',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

		