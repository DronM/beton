/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleOwnerList_View(id,options){	

	VehicleOwnerList_View.superclass.constructor.call(this,id,options);

	var model = options.models.VehicleOwnerList_Model;
	var contr = new VehicleOwner_Controller();
	
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
						new GridCellHead(id+":grid:head:name",{
							"value":"Владелец",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":"150"
									}
								})
							],
							"sortable":true,
							"sort":"asc"														
						})
						,new GridCellHead(id+":grid:head:client_list",{
							"value":"Клиенты",
							"columns":[
								new GridColumn({
									"field":model.getField("client_list"),
									"ctrlClass":null,
									"ctrlBindFieldId":null,
									"ctrlOptions":{
										"enabled":false,
										"labelCaption":false
									},
									"master":true,
									"detailViewClass":VehicleOwnerClientList_View,
									"detailViewOptions":{
										"detailFilters":{
											"VehicleOwnerClientList_Model":[
												{
												"masterFieldId":"id",
												"field":"vehicle_owner_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}																											
									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Аккаунт",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"ctrlClass":UserEditRef,
									"ctrlBindFieldId":"user_id",
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							],
							"sortable":true
						})
						/*
						,new GridCellHead(id+":grid:head:last_concrete_costs_for_owner_h_ref",{
							"value":"Прайс бетон",
							"columns":[
								new GridColumnRef({
									"field":model.getField("last_concrete_costs_for_owner_h_ref"),
									"ctrlClass":null,
									"ctrlBindFieldId":null,
									"ctrlOptions":{
										"enabled":false,
										"labelCaption":false
									},
									"master":true,
									"detailViewClass":VehicleOwnerConcretePriceList_View,
									"detailViewOptions":{
										"detailFilters":{
											"VehicleOwnerConcretePriceList_Model":[
												{
												"masterFieldId":"id",
												"field":"vehicle_owner_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}																											
								})
							],
							"sortable":true
						})
						*/
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
extend(VehicleOwnerList_View,ViewAjxList);
