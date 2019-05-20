/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function AstCallList_View(id,options){	

	AstCallList_View.superclass.constructor.call(this,id,options);

	var model = options.models.AstCallList_Model;
	var contr = new AstCall_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("start_time")
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
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEdit(id+":filter-ctrl-client",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("client_id")}),
			"sign":"e"		
		}
		,"client_tel":{
			"binding":new CommandBinding({
				"control":new EditPhone(id+":filter-ctrl-client_tel",{
					"contClassName":"form-group-filter",
					"labelCaption":"Номер клиента"
				}),
				"field":new FieldString("caller_id_num")}),
			"sign":"e"		
		}
		
		,"call_type":{
			"binding":new CommandBinding({
				"control":new Enum_call_types(id+":filter-ctrl-call_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Вид звонка:"
				}),
				"field":new FieldString("call_type")}),
			"sign":"e"		
		}/*
		,"ours":{
			"binding":new CommandBinding({
				"control":new VehicleEdit(id+":filter-ctrl-vehicle",{
					"contClassName":"form-group-filter",
					"labelCaption":"ТС:"
				}),
				"field":new FieldInt("vehicle_id")}),
			"sign":"e"		
		}
		*/
		,"client_come_from":{
			"binding":new CommandBinding({
				"control":new ClientComeFromEdit(id+":filter-ctrl-client_come_from",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("client_come_from_id")}),
			"sign":"e"		
		}
		,"client_type":{
			"binding":new CommandBinding({
				"control":new ClientTypeEdit(id+":filter-ctrl-client_type",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("client_type_id")}),
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
		"keyIds":["unique_id"],
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
						new GridCellHead(id+":grid:head:start_time_date",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"id":"start_time_date",
									"field":model.getField("start_time")
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:start_time_time",{
							"value":"Время",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"id":"start_time_time",
									"field":model.getField("start_time"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:num",{
							"value":"Звонок",
							"columns":[
								new GridColumn({
									"field":model.getField("num")
								})
							]
						})						
						,new GridCellHead(id+":grid:head:client_tel",{
							"value":"Номер клиента",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("caller_id_num")
								})
							]
						})						
						
						,new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Контрагент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
									"form":Client_Form
									,"ctrlClass":ClientEdit
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:ours",{
							"value":"Наш",
							"columns":[
								new GridColumnBool({
									"field":model.getField("ours")
								})
							]
						})
					
						,new GridCellHead(id+":grid:head:client_comment",{
							"value":"Комментарий к клиенту",
							"columns":[
								new GridColumn({
									"field":model.getField("client_comment")
								})
							]
						})
						,new GridCellHead(id+":grid:head:dur_time",{
							"value":"Прод-сть",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("dur_time"),
									"dateFormat":"H:i:s"
								})
							]
						})
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Сотрудник",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"form":User_Form,
									"ctrlClass":UserEditRef,
									"searchOptions":{
										"field":new FieldInt("user_id"),
										"searchType":"on_match"
									}									
									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:client_come_from",{
							"value":"Источник",
							"columns":[
								new GridColumnRef({
									"field":model.getField("client_come_from_ref")
								})
							]
						})
						,new GridCellHead(id+":grid:head:client_kind",{
							"value":"Вид клиента",
							"columns":[
								new EnumGridColumn_client_kinds({
									"field":model.getField("client_kind")
								})
							]
						})
						,new GridCellHead(id+":grid:head:client_type",{
							"value":"Тип клиента",
							"columns":[
								new GridColumnRef({
									"field":model.getField("client_types_ref"),
									"ctrlClass":ClientTypeEdit,
									"searchOptions":{
										"field":new FieldInt("client_type_id"),
										"searchType":"on_match"
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:call_type",{
							"value":"Звонок",
							"columns":[
								new EnumGridColumn_call_types({
									"field":model.getField("call_type")
								})
							]
						})
						,new GridCellHead(id+":grid:head:offer_quant",{
							"value":"Кол-во",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("offer_quant")
								})
							]
						})
						,new GridCellHead(id+":grid:head:offer_total",{
							"value":"Сумма",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("offer_total")
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
extend(AstCallList_View,ViewAjxList);

