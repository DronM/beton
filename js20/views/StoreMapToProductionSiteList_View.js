/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function StoreMapToProductionSiteList_View(id,options){	

	StoreMapToProductionSiteList_View.superclass.constructor.call(this,id,options);

	var model = options.models.StoreMapToProductionSiteList_Model;
	var contr = new StoreMapToProductionSite_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjxScroll(id+":grid",{
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
						new GridCellHead(id+":grid:head:store",{
							"value":"Места хранения в весовой программе",
							"columns":[
								new GridColumn({
									"field":model.getField("store")
								})
							],
							"sortable":true,
							"sort":"asc"														
						})
						,new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlBindFieldId":"production_site_id",
									"ctrlOptions":{
										"labelCaption":""
									},
									"searchOptions":{
										"field":new FieldInt("production_site_id"),										
										"searchType":"on_match"
									}									
								})
							]
						})	
						,new GridCellHead(id+":grid:head:load_capacity",{
							"value":"Вместимость материала, т.",
							"columns":[
								new GridColumn({
									"field":model.getField("load_capacity")
									//,"ctrlClass":EditNum
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
		//"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(StoreMapToProductionSiteList_View,ViewAjxList);


