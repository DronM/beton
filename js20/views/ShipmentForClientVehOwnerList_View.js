/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentForClientVehOwnerList_View(id,options){	

	ShipmentForClientVehOwnerList_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	var model = options.models.ShipmentForClientVehOwnerList_Model;
	var contr = new Shipment_Controller();

	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);

	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("ship_date")
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
	
	filters.driver = {
		"binding":new CommandBinding({
			"control":new EditString(id+":filter-ctrl-driver",{
				"contClassName":"form-group-filter",
				"labelCaption":"Водитель:"
			}),
			"field":new FieldString("drivers_ref->descr")}),
		"sign":"lk"		
	}
	filters.vehicle = {
		"binding":new CommandBinding({
			"control":new EditString(id+":filter-ctrl-vehicle",{
				"contClassName":"form-group-filter",
				"labelCaption":"ТС:"
			}),
			"field":new FieldString("vehicles_ref->descr")}),
		"sign":"lk"		
	};

	/*filters.destination = {
		"binding":new CommandBinding({
			"control":new DestinationEdit(id+":filter-ctrl-destination",{
				"contClassName":"form-group-filter",
				"labelCaption":"Объект:"
			}),
			"field":new FieldInt("destination_id")}),
		"sign":"e"		
	};*/
	filters.concrete_type = {
		"binding":new CommandBinding({
			"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
				"contClassName":"form-group-filter",
				"labelCaption":"Марка:"
			}),
			"field":new FieldInt("concrete_type_id")}),
		"sign":"e"		
	};	
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,		
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_list_for_client_veh_owner"),
		"editInline":false,
		"editWinClass":ShipmentDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
			//"cmdExport":false
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:ship_date",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("ship_date"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDateTime("ship_date")
									}																		
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Клиент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
									"ctrlClass":EditString,
									"searchOptions":{
										"field":new FieldString("clients_ref->descr"),
										"searchType":"on_part",
										"typeChange":true
									},
									"form":null
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:destinations_ref",{
							"value":"Объект",
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref"),
									"ctrlClass":EditString,
									"searchOptions":{
										"field":new FieldString("destinations_ref->descr"),
										"searchType":"on_part",
										"typeChange":true
									},
									"form":null
								})
							]
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
						,new GridCellHead(id+":grid:head:quant",{
							"value":"Количество",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("quant")
								})
							]
						})
						,new GridCellHead(id+":grid:head:cost_shipment",{
							"value":"Стоимость доставки",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost_shipment")
								})
							]
						})
						,new GridCellHead(id+":grid:head:cost_concrete",{
							"value":"Стоимость бетона",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost_concrete")
								})
							]
						})						
						,new GridCellHead(id+":grid:head:cost_other_owner_pump",{
							"value":"Стоимость чужего насоса",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost_other_owner_pump")
								})
							]
						})						
						,new GridCellHead(id+":grid:head:cost_demurrage",{
							"value":"Простой",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost_demurrage")
								})
							]
						})						
						
						,new GridCellHead(id+":grid:head:cost_total",{
							"value":"Итого",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost_total")
								})
							]
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
							"colSpan":"4"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCellFoot(id+":grid:foot:tot_cost_shipment",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_cost_shipment",
							"gridColumn":new GridColumnFloat({"id":"tot_cost_shipment"})
						})
						,new GridCellFoot(id+":grid:foot:tot_cost_concrete",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_cost_concrete",
							"gridColumn":new GridColumnFloat({"id":"tot_cost_concrete"})
						})
						,new GridCellFoot(id+":grid:foot:tot_cost_other_owner_pump",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_cost_other_owner_pump",
							"gridColumn":new GridColumnFloat({"id":"tot_cost_other_owner_pump"})
						})
						,new GridCellFoot(id+":grid:foot:tot_cost_demurrage",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_cost_demurrage",
							"gridColumn":new GridColumnFloat({"id":"tot_cost_demurrage"})
						})
						
						,new GridCellFoot(id+":grid:foot:tot_cost_total",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_cost_total",
							"gridColumn":new GridColumnFloat({"id":"tot_cost_total"})
						})
						
					]
				})		
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ShipmentForClientVehOwnerList_View,ViewAjxList);
