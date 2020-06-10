/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderForClientList_View(id,options){	

	options.templateOptions = options.templateOptions || {};
	options.templateOptions.HEAD_TITLE = "Журнал заявок";

	OrderForClientList_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	var model = options.models.OrderForClientList_Model;
	var contr = new Order_Controller();

	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);

	var period_ctrl = new EditPeriodWeek(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
		,"onChange":function(dFrom,dTo){
			self.setGridFilter(dFrom,dTo);
			window.setGlobalWait(true);
			self.getElement("grid").onRefresh(function(){
				window.setGlobalWait(false);
			});			
		}		
	});

	
	/*
	var filters = {};
	{
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
	filters.destination = {
		"binding":new CommandBinding({
			"control":new DestinationForClientEdit(id+":filter-ctrl-destination",{
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
	*/
	
	this.addElement(period_ctrl);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		//"className":"table-bordered table-responsive",//table-make_order order_make_grid
		"model":model,
		"controller":contr,
		"keyIds":["id"],
		"readPublicMethod":contr.getPublicMethod("get_list_for_client"),
		"editInline":false,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false
			,"cmdEdit":false
			,"cmdDelete":false
			,"cmdFilter":false
			,"filters":null
			//,"variantStorage":options.variantStorage
		}),
		
		//Все как в OrderMakeGrid
		"onEventSetRowOptions":function(opts){
			opts.className = opts.className||"";
			var m = this.getModel();
			var quant_rest = m.getFieldValue("quant_balance");
			var quant = m.getFieldValue("quant_ordered");
							
			if(quant_rest==0){
				opts.className+= (opts.className.length? " ":"")+"order_closed";
			}
			else if (quant_rest==quant
			&&m.getFieldValue("date_time").getTime()<(DateHelper.time()).getTime() ){
				opts.className+= (opts.className.length? " ":"")+"order_not_started";
			}
			else if (quant_rest!=quant){
				opts.className+= (opts.className.length? " ":"")+"order_started";
			}
			
			//&&quant_rest&&quant_rest!=quant
			if (m.getFieldValue("no_ship_mark")){
				opts.className+= (opts.className.length? " ":"")+"order_no_ship_for_long";
			}
			
		},
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:ship_date",{
							"value":"Дата",
							"attrs":{"rowspan":"2"},
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDateTime,
									"searchOptions":{
										"field":new FieldDate("date_time")
										,"searchType":"on_part",
									},
									"master":true,
									"detailViewClass":ShipmentForOrderList_View,
									"detailViewOptions":{
										"detailFilters":{
											"ShipmentForOrderList_Model":[
												{
												"masterFieldId":"id",
												"field":"order_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}
																											
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:number",{
							"value":"Номер",
							"attrs":{"rowspan":"2"},
							"columns":[
								new GridColumn({
									"field":model.getField("number"),
									"ctrlClass":EditString,
									"ctrlOotions":{
										"length":10
									},
									"searchOptions":{
										"field":new FieldString("number"),
										"searchType":"on_part",
										"typeChange":false
									},
									"form":null
								})
							],
							"sortable":true
						})
						
						,new GridCellHead(id+":grid:head:destinations_ref",{
							"value":"Объект",
							"attrs":{"rowspan":"2"},
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref"),
									"ctrlClass":DestinationForClientEdit,
									"searchOptions":{
										"field":new FieldInt("destination_id"),
										"searchType":"on_match",
										"typeChange":false
									},
									"form":null
								})
							],
							"sortable":true
						})
					
						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"attrs":{"rowspan":"2"},
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
						,new GridCellHead(id+":grid:head:quant_title",{
							"value":"Количество",
							"attrs":{"colspan":"3"}
						})						
					]
				})
				,new GridRow(id+":grid:head:row1",{
					"elements":[
						new GridCellHead(id+":grid:head:row1:quant_ordered",{
							"value":"Завялено",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("quant_ordered")
								})
							]
						})						
						
						,new GridCellHead(id+":grid:head:row1:quant_shipped",{
							"value":"Отгружено",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("quant_shipped")
								})
							]
						})						
						
						,new GridCellHead(id+":grid:head:row1:quant_balance",{
							"value":"Остаток",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("quant_balance")
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
						,new GridCellFoot(id+":grid:foot:tot_quant_ordered",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant_ordered",
							"gridColumn":new GridColumnFloat({"id":"tot_quant_ordered"})
						})
						,new GridCellFoot(id+":grid:foot:tot_quant_shipped",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant_shipped",
							"gridColumn":new GridColumnFloat({"id":"tot_quant_shipped"})
						})
						,new GridCellFoot(id+":grid:foot:tot_quant_balance",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant_balance",
							"gridColumn":new GridColumnFloat({"id":"tot_quant_balance"})
						})
						
					]
				})		
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":false,
		"selectedRowClass":"order_current_row",
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));
	
	this.setGridFilter(period_ctrl.getDateFrom(),period_ctrl.getDateTo());		
}
extend(OrderForClientList_View,ViewAjxList);

OrderForClientList_View.prototype.setGridFilter = function(dFrom,dTo){
	dFrom = DateHelper.getStartOfShift(dFrom);	
	dTo = DateHelper.getEndOfShift(dTo);
	var gr = this.getElement("grid");
	gr.setFilter({
		"field":"date_time"
		,"sign":"ge"
		,"val":DateHelper.format(dFrom,"Y-m-d H:i:s")
	});
	gr.setFilter({
		"field":"date_time"
		,"sign":"le"
		,"val":DateHelper.format(dTo,"Y-m-d H:i:s")
	});
}

