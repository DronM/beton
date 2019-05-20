/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function PumpVehicleList_View(id,options){	

	PumpVehicleList_View.superclass.constructor.call(this,id,options);

	var model = options.models.PumpVehicleList_Model;
	var contr = new PumpVehicle_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var is_v_owner = (window.getApp().getServVar("role_id")=="vehicle_owner");
	
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
				"control":new VehicleOwnerEdit(id+":filter-ctrl-owner",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("vehicle_owner_id")}),
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
			"variantStorage":options.variantStorage,
			"cmdDelete":!is_v_owner,
			"cmdInsert":!is_v_owner,
			"cmdCopy":!is_v_owner,
			"cmdEdit":!is_v_owner			
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
									/*"formatFunction":function(f){
										var res = "";
										var v = f.pump_vehicles_ref.getValue();
										if(v&&!v.isNull()){
											res = v.getDescr();
											v = f.owner.getValue();
											if(v){
												res = res + " ("+v+")";
											}
										}
										return res;
									},*/
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id"
								})
							],
							"sort":"asc",
							"sortable":true
						})
						,is_v_owner? null:new GridCellHead(id+":grid:head:vehicle_owner",{
							"value":"Владелец",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicle_owners_ref"),
									"ctrlClass":VehicleOwnerEdit,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							],
							"sortable":true
						})						
						
						,new GridCellHead(id+":grid:head:phone_cel",{
							"value":"Телефон",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("phone_cel")
									})
							]
						})						
						,is_v_owner? null:new GridCellHead(id+":grid:head:pump_prices_ref",{
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
						,new GridCellHead(id+":grid:head:pump_length",{
							"value":"Длина подачи",
							"columns":[
								new GridColumn({
									"field":model.getField("pump_length"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"labelCaption":""
									}									
								})
							]
						})						
						,is_v_owner? null:new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text"),
									"ctrlClass":EditString,
									"ctrlBindFieldId":"comment_text",
									"ctrlOptions":{
										"maxLength":"100"
									}
								})
							]
						})						
												
						,is_v_owner? null:new GridCellHead(id+":grid:head:deleted",{
							"value":"Удален",
							"columns":[
								new GridColumnBool({
									"field":model.getField("deleted"),
									"showFalse":false,
									"ctrlClass":EditCheckBox,
									"ctrlBindFieldId":"deleted"
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
