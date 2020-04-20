/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ProductionList_View(id,options){	

	ProductionList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ProductionList_Model;
	var contr = new Production_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	

	var production_dt_start_ctrl = new EditPeriodDate(id+":filter-ctrl-production_dt_start",{
		"field":new FieldDateTime("production_dt_start")
	});

	var production_dt_end_ctrl = new EditPeriodDate(id+":filter-ctrl-production_dt_end",{
		"field":new FieldDateTime("production_dt_start")
	});
	
	var filters = {
		"production_dt_start":{
			"binding":new CommandBinding({
				"control":production_dt_start_ctrl,
				"field":production_dt_start_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":production_dt_start_ctrl.getControlFrom(),
					"field":production_dt_start_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":production_dt_start_ctrl.getControlTo(),
					"field":production_dt_start_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
		,"production_dt_end":{
			"binding":new CommandBinding({
				"control":production_dt_end_ctrl,
				"field":production_dt_end_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":production_dt_end_ctrl.getControlFrom(),
					"field":production_dt_end_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":production_dt_end_ctrl.getControlTo(),
					"field":production_dt_end_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
		
		,"production_id":{
			"binding":new CommandBinding({
				"control":new EditString(id+":filter-ctrl-production_id",{
					"contClassName":"form-group-filter",
					"labelCaption":"№ производства:"
				}),
				"field":new FieldInt("production_id")}),
			"sign":"e"		
		}
		,"production_user":{
			"binding":new CommandBinding({
				"control":new EditString(id+":filter-ctrl-production_user",{
					"maxLength":"100",
					"contClassName":"form-group-filter",
					"labelCaption":"Пользователь:"
				}),
				"field":new FieldString("production_user")}),
			"sign":"e"		
		}
		,"production_site":{
			"binding":new CommandBinding({
				"control":new ProductionSiteEdit(id+":filter-ctrl-production_site",{
					"contClassName":"form-group-filter",
					"labelCaption":"Завод:"
				}),
				"field":new FieldString("production_site_id")}),
			"sign":"e"		
		}
		,"concrete_type":{
			"binding":new CommandBinding({
				"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Марка:"
				}),
				"field":new FieldString("concrete_type_id")}),
			"sign":"e"		
		}
		,"order":{
			"binding":new CommandBinding({
				"control":new OrderEdit(id+":filter-ctrl-order",{
					"contClassName":"form-group-filter",
					"labelCaption":"Заявка:"
				}),
				"field":new FieldString("order_id")}),
			"sign":"e"		
		}
		,"shipment":{
			"binding":new CommandBinding({
				"control":new OrderEdit(id+":filter-ctrl-shipment",{
					"contClassName":"form-group-filter",
					"labelCaption":"Отгрузка:"
				}),
				"field":new FieldString("shipment_id")}),
			"sign":"e"		
		}
		,"vehicle":{
			"binding":new CommandBinding({
				"control":new OrderEdit(id+":filter-ctrl-vehicle",{
					"contClassName":"form-group-filter",
					"labelCaption":"ТС:"
				}),
				"field":new FieldString("vehicle_id")}),
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
			"filters":filters
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:production_id",{
							"value":"№ произв-ва",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("production_id")
								})
							]
						})
					
						,new GridCellHead(id+":grid:head:production_dt_start",{
							"value":"Дата начала",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("production_dt_start")
								})
							]
						})
						,new GridCellHead(id+":grid:head:dt_start_set",{
							"value":"Установка даты начала",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("dt_start_set")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:production_dt_end",{
							"value":"Дата окончания",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("production_dt_end")
								})
							]
						})
						,new GridCellHead(id+":grid:head:dt_end_set",{
							"value":"Установка даты окончания",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("dt_end_set")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:production_user",{
							"value":"Пользователь",
							"columns":[
								new GridColumn({
									"field":model.getField("production_user")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({"field":model.getField("production_sites_ref")
								})
							]
						})	
						,new GridCellHead(id+":grid:head:orders_ref",{
							"value":"Заявка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("orders_ref"),
									"form":OrderDialog_Form
								})
							]
						})	
						,new GridCellHead(id+":grid:head:shipments_ref",{
							"value":"Отгрузка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("shipments_ref"),
									"form":ShipmentDialog_Form
								})
							]
						})	
						,new GridCellHead(id+":grid:head:vehicle_schedules_ref",{
							"value":"Экипаж",
							"columns":[
								new GridColumnRef({"field":model.getField("vehicle_schedules_ref")
								})
							]
						})	
						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"columns":[
								new GridColumnRef({"field":model.getField("concrete_types_ref")
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
extend(ProductionList_View,ViewAjx);
