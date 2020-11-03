/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function ProductionVehicleCorrectionList_View(id,options){	

	ProductionVehicleCorrectionList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ProductionVehicleCorrectionList_Model;
	var contr = new ProductionVehicleCorrection_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["production_site_id","production_id"],
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
							]
						})
						,new GridCellHead(id+":grid:head:production_id",{
							"value":"№ производства",
							"columns":[
								new GridColumn({
									"field":model.getField("production_id")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:vehicles_ref",{
							"value":"ТС",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicles_ref"),
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id"
								})
							]
						})
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь",
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
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time")
								})
							],
							"sortable":true,
							"sort":"desc"
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
extend(ProductionVehicleCorrectionList_View,ViewAjxList);
