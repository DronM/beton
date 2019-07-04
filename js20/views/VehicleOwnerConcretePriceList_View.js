/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleOwnerConcretePriceList_View(id,options){	

	VehicleOwnerConcretePriceList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.VehicleOwnerConcretePriceList_Model)? options.models.VehicleOwnerConcretePriceList_Model : new VehicleOwnerConcretePriceList_Model();
	var contr = new VehicleOwnerConcretePrice_Controller();
	
	var popup_menu = new PopUpMenu();
	var pagination = null,refresh_int = 0;
	
	if(!options.detailFilters){
		var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);	
		refresh_int = constants.grid_refresh_interval.getValue()*1000;
		
		var pagClass = window.getApp().getPaginationClass();
		pagination = new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()});		
	}
	
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["vehicle_owner_id","date","client_id"],
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":options.detailFilters? true:false,
			"cmdEdit":options.detailFilters? true:false,
			"cmdDelete":options.detailFilters? true:false,
			"filters":null,
			"cmdSearch":options.detailFilters? false:true,
			"variantStorage":options.variantStorage
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						options.detailFilters? null:new GridCellHead(id+":grid:head:vehicle_owners_ref",{
							"value":"Владелец",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicle_owners_ref"),
									"ctrlClass":VehicleOwnerEdit,
									"ctrlBindFieldId":"vehicle_owner_id",
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:date",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({
									"field":model.getField("date"),
									"ctrlClass":EditDate,
									"ctrlOptions":{
										"labelCaption":"",
										"value":DateHelper.time()
									}
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						
						,new GridCellHead(id+":grid:head:concrete_costs_for_owner_h_ref",{
							"value":"Прайс бетон",
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_costs_for_owner_h_ref"),
									"ctrlClass":ConcreteCostForOwnerHeadEdit,
									"ctrlBindFieldId":"concrete_costs_for_owner_h_id",
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})
						
					]
				})
			]
		}),
		"filters":options.detailFilters? options.detailFilters.VehicleOwnerConcretePriceList_Model:null,
		"pagination":pagination,				
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":refresh_int,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(VehicleOwnerConcretePriceList_View,ViewAjxList);
