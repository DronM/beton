/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function PumpVehicleList_View(id,options){	

	PumpVehicleList_View.superclass.constructor.call(this,id,options);

	var model = options.models.PumpVehicleList_Model;
	var contr = new PumpVehicle_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var filters = {
		"make":{
			"binding":new CommandBinding({
				"control":new MakeEdit(id+":filter-ctrl-make",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("make")}),
			"sign":"e"		
		}
		,"owner":{
			"binding":new CommandBinding({
				"control":new OwnerEdit(id+":filter-ctrl-owner",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("owner")}),
			"sign":"e"		
		}
		,"feature":{
			"binding":new CommandBinding({
				"control":new FeatureEdit(id+":filter-ctrl-feature",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("feature")}),
			"sign":"e"		
		}

	}
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:pump_vehicles_ref",{
							"value":"Автомобиль",
							"columns":[
								new GridColumnRef({
									"field":model.getField("pump_vehicles_ref"),
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id"
								})
							],
							"sort":"asc"
						})
						,new GridCellHead(id+":grid:head:phone_cel",{
							"value":"Телефон",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("phone_cel")
									})
							]
						})						
						,new GridCellHead(id+":grid:head:pump_prices_ref",{
							"value":"Ценовая схема",
							"columns":[
								new GridColumnRef({
									"field":model.getField("pump_prices_ref"),
									"ctrlClass":PumpPriceEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"pump_price_id"
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
extend(PumpVehicleList_View,ViewAjxList);
