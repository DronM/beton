/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function UserMapToProductionList_View(id,options){	
	options = options || {};
	options.models = options.models || {};
	
	UserMapToProductionList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.UserMapToProductionList_Model? false:true;
	var model = options.models.UserMapToProductionList_Model? options.models.UserMapToProductionList_Model : new UserMapToProductionList_Model();
	var contr = new UserMapToProduction_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
		}),
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
							]
						})
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь в этой программе",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"ctrlClass":UserEditRef,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"user_id"
								})
							]
						})
						,new GridCellHead(id+":grid:head:production_descr",{
							"value":"Пользователь в производстве",
							"columns":[
								new GridColumn({
									"field":model.getField("production_descr")
								})
							]
						})
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":auto_refresh,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	


}
extend(UserMapToProductionList_View,ViewAjxList);
