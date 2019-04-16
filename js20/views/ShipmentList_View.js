/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function ShipmentList_View(id,options){	

	ShipmentList_View.superclass.constructor.call(this,id,options);

	var self = this;
	this.addElement(new EditString(id+":barcode",{
		"labelCaption":"Штрих код бланка:",
		"maxLength":13,
		"autofocus":true,
		"events":{
			"keypress":function(e){
				e = EventHelper.fixKeyEvent(e);
				if (e.keyCode==13){
					self.findDoc(e.target.value);
				}								
			}
			,"input":function(e){
				e = EventHelper.fixKeyEvent(e);
				if (e.keyCode==13){
					self.findDoc(e.target.value);
				}								
			}				
		}
	}));

	var model = options.models.ShipmentList_Model;
	var contr = new Shipment_Controller();

	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);

	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("ship_date_time")
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
		,"production_site":{
			"binding":new CommandBinding({
				"control":new ProductionSiteEdit(id+":filter-ctrl-production_site",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("production_site_id")}),
			"sign":"e"		
		}
	
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEdit(id+":filter-ctrl-client",{
					"contClassName":"form-group-filter",
					"labelCaption":"Контрагент:"
				}),
				"field":new FieldInt("client_id")}),
			"sign":"e"		
		}
		,"driver":{
			"binding":new CommandBinding({
				"control":new DriverEditRef(id+":filter-ctrl-driver",{
					"contClassName":"form-group-filter",
					"labelCaption":"Водитель:"
				}),
				"field":new FieldInt("driver_id")}),
			"sign":"e"		
		}
		,"vehicle":{
			"binding":new CommandBinding({
				"control":new VehicleEdit(id+":filter-ctrl-vehicle",{
					"contClassName":"form-group-filter",
					"labelCaption":"ТС:"
				}),
				"field":new FieldInt("vehicle_id")}),
			"sign":"e"		
		}
	
		,"destination":{
			"binding":new CommandBinding({
				"control":new DestinationEdit(id+":filter-ctrl-destination",{
					"contClassName":"form-group-filter",
					"labelCaption":"Объект:"
				}),
				"field":new FieldInt("destination_id")}),
			"sign":"e"		
		}
		,"concrete_type":{
			"binding":new CommandBinding({
				"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Марка:"
				}),
				"field":new FieldInt("concrete_type_id")}),
			"sign":"e"		
		}
		,"user":{
			"binding":new CommandBinding({
				"control":new UserEditRef(id+":filter-ctrl-user",{
					"contClassName":"form-group-filter",
					"labelCaption":"Автор:"
				}),
				"field":new FieldInt("user_id")}),
			"sign":"e"		
		}
	
	};

	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdInsert":false,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:id",{
							"value":"Номер",
							"columns":[
								new GridColumn({
									"field":model.getField("id")
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
				
						,new GridCellHead(id+":grid:head:ship_date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("ship_date_time"),
									"dateFormat":"d/m/y H:i"
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref"),
									"ctrlClass":ConcreteTypeEdit,
									"searchOptions":{
										"field":new FieldInt("concrete_type_id"),
										"searchType":"on_match"
									}									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:owner",{
							"value":"Владелец ТС",
							"columns":[
								new GridColumn({
									"field":model.getField("owner")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Контрагент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
									"ctrlClass":ClientEdit,
									"searchOptions":{
										"field":new FieldInt("client_id"),
										"searchType":"on_match"
									},
									"form":Client_Form																																			
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:destinations_ref",{
							"value":"Объект",
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref"),
									"ctrlClass":DestinationEdit,
									"searchOptions":{
										"field":new FieldInt("destination_id"),
										"searchType":"on_match"
									},
									"form":Destination_Form
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:vehicles_ref",{
							"value":"ТС",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicles_ref"),
									"ctrlClass":VehicleEdit,
									"searchOptions":{
										"field":new FieldInt("vehicle_id"),
										"searchType":"on_match"
									},
									"form":VehicleDialog_Form									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:drivers_ref",{
							"value":"Водитель",
							"columns":[
								new GridColumnRef({
									"field":model.getField("drivers_ref"),
									"ctrlClass":DriverEditRef,
									"searchOptions":{
										"field":new FieldInt("driver_id"),
										"searchType":"on_match"
									}									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:shipped",{
							"value":"Отгружено",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnBool({
									"field":model.getField("shipped")
								})
							]
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
						,new GridCellHead(id+":grid:head:cost",{
							"value":"Стоимость",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost"),
									"precision":2
								})
							]
						})
						,new GridCellHead(id+":grid:head:demurrage_cost",{
							"value":"За простой",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("demurrage_cost")									
								})
							]
						})
						,new GridCellHead(id+":grid:head:demurrage",{
							"value":"Время простоя",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("demurrage"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:client_mark",{
							"value":"Баллы",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("client_mark")									
								})
							]
						})
						,new GridCellHead(id+":grid:head:blanks_exist",{
							"value":"Бланки",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnBool({
									"field":model.getField("blanks_exist")									
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
							"colSpan":"10"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCellFoot(id+":grid:foot:tot_cost",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"cost",
							"gridColumn":new GridColumnFloat({"id":"tot_cost"})
						})						
											
						,new GridCellFoot(id+":grid:foot:tot_demurrage_cost",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"demurrage_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_demurrage_cost"})
						})						
					
						,new GridCell(id+":grid:foot:total_sp2",{
							"colSpan":"4"
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
extend(ShipmentList_View,ViewAjxList);

ShipmentList_View.prototype.findDoc = function(barcode){
	var pm = (new Shipment_Controller()).getPublicMethod("set_blanks_exist");
	pm.setFieldValue("barcode",barcode);
	
	var self = this;
	pm.run({
		"ok":function(resp){
			var ctrl = self.getElement("barcode");
			ctrl.reset();
			ctrl.focus();
			ctrl.getErrorControl().setValue("Документ погашен!","info");
		}
	})
}

