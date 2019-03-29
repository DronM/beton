/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderPumpList_View(id,options){	

	OrderPumpList_View.superclass.constructor.call(this,id,options);

	var model = options.models.OrderPumpList_Model;
	var contr = new OrderPump_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
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
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["order_id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":OrderDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":true,
			"cmdDelete":true,
			"cmdCopy":true,
			"cmdEdit":true,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:number",{
							"value":"Номер",
							"columns":[
								new GridColumn({
									"field":model.getField("number")
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
						,new GridCellHead(id+":grid:head:clients_ref",{
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
							"columns":[
								new GridColumn({
									"field":model.getField("quant")
								})
							]
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
						,new GridCellHead(id+":grid:head:unload_type",{
							"value":"Подача",
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
						
						,new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text")
								})
							]
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
