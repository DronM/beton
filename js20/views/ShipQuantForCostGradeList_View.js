/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShipQuantForCostGradeList_View(id,options){
	options = options || {};	
	
	ShipQuantForCostGradeList_View.superclass.constructor.call(this,id,options);
	
	
	var model = options.models.ShipQuantForCostGrade_Model;
	var contr = new ShipQuantForCostGrade_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	this.m_prevQuant = 0;
	var self = this;
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	var grid = new GridAjx(id+":grid",{
		"keyIds":["quant"],
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:quant_from",{
							"value":"Объем от",
							"columns":[
								new GridColumn({
									"id":"quant_from",
									"formatFunction":function(fields){
										return self.m_prevQuant;
									},
									"ctrlClass":Edit,
									"ctrlOptions":{
										"enabled":false
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:quant_to",{
							"value":"Объем до",
							"columns":[
								new GridColumn({
									"field":model.getField("quant"),
									"bindFieldId":"quant",
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"required":true
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:quant_for_cost",{
							"value":"Объем для доставки",
							"columns":[
								new GridColumn({
									"id":"quant_for_cost",
									"formatFunction":function(fields){
										var q = fields.quant.getValue();
										self.m_prevQuant = q+1;
										return q;
									},
									"ctrlClass":Edit,									
									"ctrlOptions":{
										"enabled":false
									}
								})
							]
						})
						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	
	this.m_gridOnGetData = grid.onGetData;
	grid.onGetData = function(resp){
		self.m_prevQuant = 0;
		self.m_gridOnGetData.call(self.getElement("grid"),resp);
	}
	this.addElement(grid);	
}
//ViewObjectAjx,ViewAjxList
extend(ShipQuantForCostGradeList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

