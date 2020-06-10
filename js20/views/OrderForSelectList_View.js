/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderForSelectList_View(id,options){	

	OrderForSelectList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.OrderList_Model)? options.models.OrderList_Model:new OrderList_Model();
	var contr = new Order_Controller();
	
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

	var grid  = new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":null,
		/*"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),*/
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdAllCommands":false
		}),
		"popUpMenu":null,
		"onSelect":options.onSelect,
		"filters":[
			{
			"field":"date_time"
			,"sign":"ge"
			,"val":DateHelper.format(DateHelper.getStartOfShift(options.dateTime),"Y-m-d H:i:s")
			}			
			,{
			"field":"date_time"
			,"sign":"le"
			,"val":DateHelper.format(DateHelper.getEndOfShift(options.dateTime),"Y-m-d H:i:s")
			}			
			
		],
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
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg"
									}
									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:number",{
							"value":"Номер",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("number")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Контрагент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
									//"form":ClientDialog_Form,
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
									//"form":Destination_Form,
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
								new GridColumnFloat({
									"field":model.getField("quant"),
									"precision":1
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
						,new GridCellHead(id+":grid:head:unload_type",{
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
							],
							"sortable":true
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
		
		"pagination":null,		
		"autoRefresh":true,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	
	this.addElement(grid);
	
}
extend(OrderForSelectList_View,ViewAjx);
