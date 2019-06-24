/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShipmentDateList_View(id,options){
	options = options || {};	
	
	ShipmentDateList_View.superclass.constructor.call(this,id,options);
	
	
	var model = options.models.ShipmentDateList_Model;
	var contr = new Shipment_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("ship_date")
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
	};
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["ship_date"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_shipment_date_list"),
		"editInline":null,
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
						new GridCellHead(id+":grid:head:ship_date",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({
									"field":model.getField("ship_date")
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:production_site",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref")
								})
							],
							"sortable":true
						})
						
						,new GridCellHead(id+":grid:head:client",{
							"value":"Клиент",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:destination",{
							"value":"Объект",
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:concrete",{
							"value":"Марка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref")
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
						,new GridCellHead(id+":grid:head:ship_cost",{
							"value":"Доставка",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("ship_cost")
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
							"value":"Простой",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnTime({
									"field":model.getField("demurrage")
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
							"colSpan":"5"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCellFoot(id+":grid:foot:tot_ship_cost",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_ship_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_ship_cost"})
						})						
												
						,new GridCellFoot(id+":grid:foot:tot_demurrage_cost",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"total_demurrage_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_demurrage_cost"})
						})						
						
						,new GridCell(id+":grid:foot:total_sp2",{
							"colSpan":"1"
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
//ViewObjectAjx,ViewAjxList
extend(ShipmentDateList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

