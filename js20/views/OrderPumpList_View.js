/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderPumpList_View(id,options){	

	OrderPumpList_View.superclass.constructor.call(this,id,options);

	var model = options.models.OrderPumpList_Model;
	var contr = new OrderPump_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var is_v_owner = (window.getApp().getServVar("role_id")=="vehicle_owner");	
	
	var filters;
	if(!is_v_owner){
		filters = {
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
			,"unload_type":{
				"binding":new CommandBinding({
					"control":new Enum_unload_types(id+":filter-ctrl-unload_type",{
						"contClassName":"form-group-filter",
						"labelCaption":"Подача:"
					}),
					"field":new FieldString("unload_type")}),
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
	}
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["order_id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":OrderDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":!is_v_owner,
			"cmdDelete":!is_v_owner,
			"cmdCopy":!is_v_owner,
			"cmdEdit":!is_v_owner,
			"cmdFilter":!is_v_owner,
			"cmdAllCommands":!is_v_owner,
			"cmdSearch":!is_v_owner,
			"filters":!is_v_owner? filters:null,
			"variantStorage":!is_v_owner? options.variantStorage:null
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
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg"
									}
								})
							],
							"sortable":true,
							"sort":"asc"
						})
					
						,is_v_owner? null:new GridCellHead(id+":grid:head:number",{
							"value":"Номер",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("number")
								})
							],
							"sortable":true
						})
						,is_v_owner? null:new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Контрагент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
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
									"ctrlClass":DestinationEdit,
									"searchOptions":{
										"field":new FieldInt("destination_id"),
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
								new GridColumn({
									"field":model.getField("quant")
								})
							]
						})
						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"colAttrs":{"align":"center"},
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
						,is_v_owner? null:new GridCellHead(id+":grid:head:unload_type",{
							"value":"Подача",
							"colAttrs":{"align":"center"},
							"columns":[
								new EnumGridColumn_unload_types({
									"field":model.getField("unload_type"),
									"ctrlClass":Enum_unload_types,
									"searchOptions":{
										"field":new FieldString("unload_type"),
										"searchType":"on_match"
									}									
									
								})
							]
						})
						
						,is_v_owner? null:new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text")
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
						
						,new GridCellHead(id+":grid:head:phone_cel",{
							"value":"Телефон",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("phone_cel")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:descr",{
							"value":"Прораб",
							"columns":[
								new GridColumn({
									"field":model.getField("descr")
								})
							],
							"sortable":true
						})
						,is_v_owner? null:new GridCellHead(id+":grid:head:pump_vehicle_owners_ref",{
							"value":"Владелец насоса",
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
						
						,is_v_owner? null:new GridCellHead(id+":grid:head:users_ref",{
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
							"colSpan":is_v_owner? "2":"4"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCell(id+":grid:foot:total_sp2",{
							"colSpan":is_v_owner? "4":"8"
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
extend(OrderPumpList_View,ViewAjx);

/*
OrderPumpList_View.prototype.setOwnerAgreed = function(btn){
	var row = btn.m_row;
	var val = btn.getValue();
	var keys = CommonHelper.unserialize(row.getAttr("keys"));
	
	var pm = this.getElement("grid").getReadPublicMethod().getController().getPublicMethod("owner_set_pump_agreed");
	pm.setFieldValue("shipment_id",keys.id);
	var slef = this;
	pm.run({
		"ok":function(resp){
			slef.getElement("grid").onRefresh();
		}
	})
	
}
*/
