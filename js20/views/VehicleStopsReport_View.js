/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function VehicleStopsReport_View(id,options){

	options = options || {};
	
	var contr = new Vehicle_Controller();	
	options.publicMethod = contr.getPublicMethod("get_stops_at_dest");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "VehicleStopsReport";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDate("date_time")
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
		,"destination":{
			"binding":new CommandBinding({
				"control":new DestinationEdit(id+":filter-ctrl-destination",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("destination_id")
			}),
			"sign":"e"
		}
		,"vehicle":{
			"binding":new CommandBinding({
				"control":new VehicleEdit(id+":filter-ctrl-vehicle",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("vehicle_id")
			}),
			"sign":"e"
		}
		,"stop_duration":{
			"binding":new CommandBinding({
				"control":new EditTime(id+":filter-ctrl-stop_duration",{
					"labelCaption":"Стоянка:",
					"contClassName":"form-group-filter",
					"value":"00:05"
				}),
				"field":new FieldTime("stop_dur")
			}),
			"sign":"e"
		}
	};

	VehicleStopsReport_View.superclass.constructor.call(this, id, options);
	
}
extend(VehicleStopsReport_View,ViewReport);

