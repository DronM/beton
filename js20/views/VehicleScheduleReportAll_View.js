/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function VehicleScheduleReportAll_View(id,options){

	options = options || {};
	
	options.publicMethod = (new VehicleSchedule_Controller()).getPublicMethod("get_schedule_report_all");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "VehicleScheduleReportAll";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("date")
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
		,"vehicle":{
			"binding":new CommandBinding({
				"control":new VehicleEdit(id+":filter-ctrl-vehicle",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("vehicle_id")
			}),
			"sign":"e"
		}
	};

	VehicleScheduleReportAll_View.superclass.constructor.call(this, id, options);
	
}
extend(VehicleScheduleReportAll_View,ViewReport);

