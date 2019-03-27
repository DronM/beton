/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ShipmentTimeList_View(id,options){

	options = options || {};
	
	options.publicMethod = (new Shipment_Controller()).getPublicMethod("get_time_list");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "ShipmentTimeList";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("ship_date_time")
	});
	
	options.filters = {
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
				"field":new FieldInt("production_site_id"),
				"sendNull":false
				}),
			"sign":"e"		
		}
		
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEdit(id+":filter-ctrl-client",{
					"contClassName":"form-group-filter",
					"labelCaption":"Контрагент:"
				}),
				"field":new FieldInt("client_id")
				,"sendNull":false
				}),
			"sign":"e"		
		}
		,"driver":{
			"binding":new CommandBinding({
				"control":new DriverEditRef(id+":filter-ctrl-driver",{
					"contClassName":"form-group-filter",
					"labelCaption":"Водитель:"
				}),
				"field":new FieldInt("driver_id")
				,"sendNull":false
				}),				
			"sign":"e"		
		}
		,"vehicle":{
			"binding":new CommandBinding({
				"control":new VehicleEdit(id+":filter-ctrl-vehicle",{
					"contClassName":"form-group-filter",
					"labelCaption":"ТС:"
				}),
				"field":new FieldInt("vehicle_id")
				,"sendNull":false
				}),				
			"sign":"e"		
		}
		
		,"destination":{
			"binding":new CommandBinding({
				"control":new DestinationEdit(id+":filter-ctrl-destination",{
					"contClassName":"form-group-filter",
					"labelCaption":"Объект:"
				}),
				"field":new FieldInt("destination_id")
				,"sendNull":false
				}),				
			"sign":"e"		
		}
		
	};

	ShipmentTimeList_View.superclass.constructor.call(this, id, options);
	
}
extend(ShipmentTimeList_View,ViewReport);

