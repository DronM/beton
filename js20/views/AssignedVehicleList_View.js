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
	
	/*options.templateOptions = {
		"notFullScreen":(window.location.href.indexOf("v=Child")<0)
	};
	*/
	
	this.m_noAutoRefresh = options.noAutoRefresh;
	
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
	
		this.m_prodSiteControlList = [];
		
		var model = (options.models&&options.models.AssignedVehicleList_Model)? options.models.AssignedVehicleList_Model : new AssignedVehicleList_Model();
		app.m_prodSite_Model.reset();
		while(app.m_prodSite_Model.getNextRow()){
			var ps_id = app.m_prodSite_Model.getFieldValue("id");
			var prod_cite = new AssignedVehicleGrid(id+":prodSite"+ps_id,{
				"model":model,
				"prodSiteId":ps_id,
				"prodSiteDescr":app.m_prodSite_Model.getFieldValue("name"),
				"noAutoRefresh":options.noAutoRefresh,
				"shortDestinations":options.shortDestinations,
				"shortDescriptions":options.shortDescriptions
			});
			this.addElement(prod_cite);
			this.m_prodSiteControlList.push(prod_cite);
		}
	}
		
	AssignedVehicleList_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(AssignedVehicleList_View,View);

/* Constants */
AssignedVehicleList_View.prototype.PROD_SITE_COUNT = 2;

/* private members */
AssignedVehicleList_View.prototype.m_refreshPublicMethod;
AssignedVehicleList_View.prototype.m_refreshTimer;
AssignedVehicleList_View.prototype.m_refreshInterval;
AssignedVehicleList_View.prototype.m_prodSiteControlList;

/* protected*/


/* public methods */

AssignedVehicleList_View.prototype.toggleMenu = function(){
	var menu_n = document.body.getElementsByTagName("div");	
	if(menu_n&&menu_n.length){
		var t = document.getElementById(this.getId()+":menu_toggle");
		
		if($(menu_n[0]).is(":visible")){
			$(menu_n[0]).slideUp("slow");
						
			this.m_oldToggleTitle = t.getAttribute("title");
			this.m_oldToggleText = DOMHelper.getText(t);
			
			DOMHelper.setText(t,">");
			t.setAttribute("title","Показать меню");
		}
		else{
			$(menu_n[0]).slideDown("slow");
			
			DOMHelper.setText(t,this.m_oldToggleText);
			t.setAttribute("title",this.m_oldToggleTitle);
			
		}		
	}
}

AssignedVehicleList_View.prototype.setData = function(m){
	for(i=1;i<=this.PROD_SITE_COUNT;i++){
		var grid = this.getElement("prodSite"+i);
		grid.getModel().setData(m);
		grid.onGetData();
	}	
}



AssignedVehicleList_View.prototype.onRefresh = function(){
	if(!this.m_refreshPublicMethod){
		this.m_refreshPublicMethod = (new Shipment_Controller()).getPublicMethod("get_assigned_vehicle_list");
	}
	var self = this;
	this.stopRefreshTimer();
	this.m_refreshPublicMethod.run({
		"ok":function(resp){
			for(var i=0;i<self.m_prodSiteControlList.length;i++){
				self.m_prodSiteControlList[i].m_model = resp.getModel("AssignedVehicleList_Model");
				self.m_prodSiteControlList[i].onGetData();
			}
			
		}
		,"all":function(){
			self.startRefreshTimer();
		}
	})
}

AssignedVehicleList_View.prototype.stopRefreshTimer = function(){
	if(this.m_refreshTimer){
		clearInterval(this.m_refreshTimer);
	}
}

AssignedVehicleList_View.prototype.startRefreshTimer = function(){
	var self = this;
	this.m_refreshTimer = setInterval(function(){
		self.onRefresh();
	},this.m_refreshInterval);
}

AssignedVehicleList_View.prototype.toDOM = function(p){
	
	AssignedVehicleList_View.superclass.toDOM.call(this,p);
	
	var self = this;
	EventHelper.add(document.getElementById(this.getId()+":menu_toggle"),"click",function(){
		self.toggleMenu();
	});
	
	if (this.m_noAutoRefresh!==true){
		var constants = {"order_grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);			
		this.m_refreshInterval = constants.order_grid_refresh_interval.getValue() * 1000;
		this.startRefreshTimer();
	}
		
}

AssignedVehicleList_View.prototype.delDOM = function(){
	this.stopRefreshTimer();
	AssignedVehicleList_View.superclass.delDOM.call(this);
}
