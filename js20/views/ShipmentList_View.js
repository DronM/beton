/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
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
	filters.driver = {
		"binding":new CommandBinding({
			"control":new DriverEditRef(id+":filter-ctrl-driver",{
				"contClassName":"form-group-filter",
				"labelCaption":"Водитель:"
			}),
			"field":new FieldInt("driver_id")}),
		"sign":"e"		
	}
	filters.vehicle = {
		"binding":new CommandBinding({
			"control":new VehicleEdit(id+":filter-ctrl-vehicle",{
				"contClassName":"form-group-filter",
				"labelCaption":"ТС:"
			}),
			"field":new FieldInt("vehicle_id")}),
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
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_list"),
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
		"onEventSetCellOptions":function(opts){
			if(opts.gridColumn.getId()=="cost"){
				opts.className = opts.className||"";
				if(this.getModel().getFieldValue("ship_cost_edit")){
					opts.title="Значение отредактирована вручную";
					opts.className+=(opts.className.length? " ":"")+"cost_edit";
				}
			}				
			else if(opts.gridColumn.getId()=="pump_cost"){
				opts.className = opts.className||"";
				if(this.getModel().getFieldValue("pump_cost_edit")){
					opts.title="Значение отредактирована вручную";
					opts.className+=(opts.className.length? " ":"")+"cost_edit";
				}
			}				
			
		},
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:ship_date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("ship_date_time"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("ship_date_time"),
										"searchType":"on_beg"
									}																		
								})
							],
							"sortable":true,
							"sort":"desc"
						})					
						,new GridCellHead(id+":grid:head:id",{
							"value":"Номер",
							"colAttrs":{"clign":"center"},
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
						,new GridCellHead(id+":grid:head:quant",{
							"value":"Количество",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("quant")
								})
							]
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
										"searchType":"on_match",
										"typeChange":false
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
										"field":(new FieldInt("driver_id")),
										"searchType":"on_match",
										"typeChange":false
									}
								})
							],
							"sortable":true
						})
						
						,new GridCellHead(id+":grid:head:vehicle_owners_ref",{
							"value":"Владелец ТС",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicle_owners_ref")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:cost",{
							"value":"Доставка",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("cost"),
									"precision":2
								})
							]
						})
											
						,new GridCellHead(id+":grid:head:demurrage",{
							"value":"Время простоя",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("demurrage")
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
						,new GridCellHead(id+":grid:head:pump_cost",{
							"value":"Стоим.насос",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("pump_cost")									
								})
							]
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
						,new GridCellHead(id+":grid:head:acc_comment",{
							"value":"Бух.коммент.",
							"columns":[
								new GridColumn({
									"field":model.getField("acc_comment")
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
							],
							"sortable":true
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
						,new GridCellHead(id+":grid:head:owner_pump_agreed_date_time",{
							"value":"Согл.насос",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("owner_pump_agreed_date_time"),
									"dateFormat":"d/m/y"
								})
								]
						})
						,new GridCellHead(id+":grid:head:owner_agreed_date_time",{
						"value":"Согл.миксер",
						"colAttrs":{"align":"center"},
						"columns":[
							new GridColumnDate({
								"field":model.getField("owner_agreed_date_time"),
								"dateFormat":"d/m/y"
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
							"colSpan":"6"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCell(id+":grid:foot:total_sp2",{
							"colSpan":"3"
						})											
						
						,new GridCellFoot(id+":grid:foot:tot_cost",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"cost",
							"gridColumn":new GridColumnFloat({"id":"tot_cost"})
						})						
						,new GridCell(id+":grid:foot:total_sp4",{
							"colSpan":"1"
						})											
											
						,new GridCellFoot(id+":grid:foot:tot_demurrage_cost",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"demurrage_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_demurrage_cost"})
						})						
						,new GridCellFoot(id+":grid:foot:tot_pump_cost",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"pump_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_pump_cost"})
						})						
					
						,new GridCell(id+":grid:foot:total_sp3",{
							"colSpan":"7"
						})						
					]
				})		
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":false,
		"refreshInterval":0,//constants.grid_refresh_interval.getValue()*1000,
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
			
			window.showTempNote("Документ погашен!",1000);
		}
	})
}

