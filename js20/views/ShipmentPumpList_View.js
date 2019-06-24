/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentPumpList_View(id,options){	

	ShipmentPumpList_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	var model = options.models.ShipmentPumpList_Model;
	var contr = new Shipment_Controller();

	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);

	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});

	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
	};
	
	filters.production_site = {
		"binding":new CommandBinding({
			"control":new ProductionSiteEdit(id+":filter-ctrl-production_site",{
				"contClassName":"form-group-filter"
			}),
			"field":new FieldInt("production_site_id")}),
		"sign":"e"		
	};

	filters.client = {
		"binding":new CommandBinding({
			"control":new ClientEdit(id+":filter-ctrl-client",{
				"contClassName":"form-group-filter",
				"labelCaption":"Контрагент:"
			}),
			"field":new FieldInt("client_id")}),
		"sign":"e"		
	};
	filters.destination = {
		"binding":new CommandBinding({
			"control":new DestinationEdit(id+":filter-ctrl-destination",{
				"contClassName":"form-group-filter",
				"labelCaption":"Объект:"
			}),
			"field":new FieldInt("destination_id")}),
		"sign":"e"		
	};
	filters.concrete_type = {
		"binding":new CommandBinding({
			"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
				"contClassName":"form-group-filter",
				"labelCaption":"Марка:"
			}),
			"field":new FieldInt("concrete_type_id")}),
		"sign":"e"		
	};
	
	filters.user = {
		"binding":new CommandBinding({
			"control":new UserEditRef(id+":filter-ctrl-user",{
				"contClassName":"form-group-filter",
				"labelCaption":"Автор:"
			}),
			"field":new FieldInt("user_id")}),
		"sign":"e"		
	};	
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["last_ship_id"],
		"readPublicMethod":contr.getPublicMethod("get_pump_list"),
		"editInline":false,
		"editWinClass":ShipmentDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":true,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
			//"cmdExport":!is_v_owner
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg"
									}																		
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:order_number",{
							"value":"Номер",
							"colAttrs":{"clign":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("order_number")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"searchOptions":{
										"field":new FieldInt("production_site_id"),
										"searchType":"on_match"
									}
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Контрагент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
									"form":ClientDialog_Form,
									"ctrlClass":ClientEdit,
									"searchOptions":{
										"field":new FieldInt("client_id"),
										"searchType":"on_match"
									}
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:destinations_ref",{
							"value":"Объект",
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref"),
									"form":Destination_Form,
									"ctrlClass":DestinationEdit,
									"searchOptions":{
										"field":(new FieldInt("destination_id")),
										"searchType":"on_match",
										"typeChange":false
									}
								})
							],
							"sortable":true
						})
										
						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"colAttrs":{"clign":"center"},
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref"),
									"ctrlClass":ConcreteTypeEdit,
									"searchOptions":{
										"field":new FieldInt("concrete_type_id"),
										"searchType":"on_match",
										"typeChange":false
									}									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:pump_vehicles_ref",{
							"value":"Насос",
							"columns":[
								new GridColumnRef({
									"field":model.getField("pump_vehicles_ref"),
									"ctrlClass":PumpVehicleEdit,
									"searchOptions":{
										"field":new FieldInt("pump_vehicle_id"),
										"searchType":"on_match"
									}																										
								})
							],
							"sortable":true
						})						
						,new GridCellHead(id+":grid:head:pump_vehicle_owners_ref",{
							"value":"Насос,влад.",
							"columns":[
								new GridColumnRef({
									"field":model.getField("pump_vehicle_owners_ref"),
									"ctrlClass":VehicleOwnerEdit,
									"searchOptions":{
										"field":new FieldInt("pump_vehicle_owner_id"),
										"searchType":"on_match"
									}																										
								})
							],
							"sortable":true
						})						
						
						,new GridCellHead(id+":grid:head:quant",{
							"value":"Количество",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant")
								})
							]
						})
						,new GridCellHead(id+":grid:head:pump_cost",{
							"value":"Стоим.насос",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("pump_cost")									
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:acc_comment",{
							"value":"Комментарий",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("acc_comment")
								})
							]
						})						
						,new GridCellHead(id+":grid:head:owner_pump_agreed_date_time",{
							"value":"Согл.миксер",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("owner_pump_agreed_date_time"),
									"dateFormat":"d/m/y"
								})
							]
						})
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Автор",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"ctrlClass":UserEditRef,
									"searchOptions":{
										"field":new FieldInt("user_id"),
										"searchType":"on_match"
									}																										
								})
							],
							"sortable":true
						})
					]
				})
			]
		}),
		"foot":new GridFoot(id+"grid:foot",{
			"autoCalc":true,			
			"elements":[
				new GridRow(id+":grid:foot:row0",{
					"elements":[
						new GridCell(id+":grid:foot:total_sp1",{
							"colSpan":"8"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCellFoot(id+":grid:foot:tot_pump_cost",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_pump_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_pump_cost"})
						})						
											
						,new GridCell(id+":grid:foot:total_sp3",{
							"colSpan":"3"
						})						
					]
				})		
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":false,
		"refreshInterval":0,//constants.grid_refresh_interval.getValue()*1000
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ShipmentPumpList_View,ViewAjxList);

