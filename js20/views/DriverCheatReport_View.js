/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function DriverCheatReport_View(id,options){

	options = options || {};
	
	options.publicMethod = (new Driver_Controller()).getPublicMethod("driver_cheat_report");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "DriverCheatReport";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var end_d = DateHelper.getEndOfShift(DateHelper.getStartOfShift(DateHelper.monthEnd()));
	
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
		,"cheat_end_date_time":{
			"binding":new CommandBinding({
				"control":new EditDateTime(id+":filter-ctrl-cheat_end_date_time",{
					"contClassName":"form-group-filter",
					"labelCaption":"Окончание периода контроля:",
					"value":end_d
				}),
				"field":new FieldDateTime("cheat_end_date_time")
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
					"contClassName":"form-group-filter",
					"labelCaption":"Стоянка:",
					"value":"00:05"					
				}),
				"field":new FieldTime("stop_duration")
			}),
			"sign":"e"
		}
		,"stop_spot_offset":{
			"binding":new CommandBinding({
				"control":new EditNum(id+":filter-ctrl-stop_spot_offset",{
					"contClassName":"form-group-filter",
					"labelCaption":"Отступ от стоянки (метров):",
					"value":20
				}),
				"field":new FieldInt("stop_spot_offset")
			}),
			"sign":"e"
		}
		
	};

	DriverCheatReport_View.superclass.constructor.call(this, id, options);
	
}
extend(DriverCheatReport_View,ViewReport);

