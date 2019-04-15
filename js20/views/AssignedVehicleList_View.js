/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends 
 * @requires core/extend.js
 * @requires controls/.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function AssignedVehicleList_View(id,options){
	options = options || {};	
	
	var refresh_interval = null;
	if (options.noAutoRefresh!==true){
		var constants = {"grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);	
		refresh_interval = constants.grid_refresh_interval.getValue();
	}
	
	var app = window.getApp();
	if(!app.m_prodSite_Model){
		(new ProductionSite_Controller()).getPublicMethod("get_list").run({
			"async":false,
			"ok":function(resp){
				app.m_prodSite_Model = resp.getModel("ProductionSite_Model");
			}
		})
	}
	
	options.addElement = function(){
		var model = (options.models&&options.models.AssignedVehicleList_Model)? options.models.AssignedVehicleList_Model : new AssignedVehicleList_Model();
		app.m_prodSite_Model.reset();
		while(app.m_prodSite_Model.getNextRow()){
		//for(i=1;i<=this.PROD_SITE_COUNT;i++){
			var ps_id = app.m_prodSite_Model.getFieldValue("id");
			this.addElement(new AssignedVehicleGrid(id+":prodSite"+ps_id,{
				"model":model,
				"prodSiteId":ps_id,
				"prodSiteDescr":app.m_prodSite_Model.getFieldValue("name"),
				"refreshInterval":refresh_interval
			}));
		}
	}
	
	AssignedVehicleList_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(AssignedVehicleList_View,View);

/* Constants */
AssignedVehicleList_View.prototype.PROD_SITE_COUNT = 2;

/* private members */
/* protected*/


/* public methods */
AssignedVehicleList_View.prototype.setData = function(m){
	for(i=1;i<=this.PROD_SITE_COUNT;i++){
		var grid = this.getElement("prodSite"+i);
		grid.getModel().setData(m);
		grid.onGetData();
	}	
}


/*
AssignedVehicleList_View.prototype.toDOM = function(p){
	
}
*/
