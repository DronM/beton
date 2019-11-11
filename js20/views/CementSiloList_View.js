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
function CementSiloList_View(id,options){

	options = options || {};
	
	CementSiloList_View.superclass.constructor.call(this,id,options);

	var model = options.models.CementSiloList_Model;
	var contr = new CementSilo_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
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
						new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"production_site_id"
									
								})
							],
							"sortable":true,
							"sort":"asc"							
						})						
						,new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"labelCaption":"",
										"maxLength":"100"
									}
								})
							]
						})						
						
						,new GridCellHead(id+":grid:head:production_descr",{
							"value":"Наименование в Elkon",
							"columns":[
								new GridColumn({
									"field":model.getField("production_descr"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"labelCaption":"",
										"maxLength":"100"
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:weigh_app_name",{
							"value":"Наименование в весовой прогр.",
							"columns":[
								new GridColumn({
									"field":model.getField("weigh_app_name"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"labelCaption":"",
										"maxLength":"100"
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:load_capacity",{
							"value":"Вместимость, т.",
							"columns":[
								new GridColumn({
									"field":model.getField("load_capacity"),
									"ctrlClass":EditFloat,
									"ctrlOptions":{
										"labelCaption":"",
										"precision":"4"
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:visible",{
							"value":"Показывать",
							"columns":[
								new GridColumnBool({
									"field":model.getField("visible")
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
	}));	
}
//ViewObjectAjx,ViewAjxList
extend(CementSiloList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

