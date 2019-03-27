/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function VehicleEfficiency_View(id,options){

	options = options || {};
	
	options.publicMethod = (new VehicleSchedule_Controller()).getPublicMethod("get_vehicle_efficiency");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "VehicleEfficiencyReport";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	//var d1 = new Date((DateHelper.getStartOfShift(DateHelper.monthStart())).getTime() - (new Date()).getTimezoneOffset()*60*1000);
	//var d2 = new Date((DateHelper.getEndOfShift( DateHelper.getStartOfShift(DateHelper.monthEnd()))).getTime() - (new Date()).getTimezoneOffset()*60*1000);
	var d1 = DateHelper.strtotime( DateHelper.format(DateHelper.getStartOfShift(DateHelper.monthStart()),"Y-m-dTH:i:s") + window.getApp().getTimeZoneOffsetStr() );
	var d2 = DateHelper.strtotime( DateHelper.format(DateHelper.getEndOfShift( DateHelper.getStartOfShift(DateHelper.monthEnd())),"Y-m-dTH:i:s") + window.getApp().getTimeZoneOffsetStr() );
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"valueFrom":d1,
		"valueTo":d2,
		"field":new FieldDateTime("date_time")
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
		,"run_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":run_type",{
					"labelCaption":"Тип рейсов:",
					"elements":[
						new EditSelectOption(id+":run_type:run_type_all_sum",{"descr":"Все"})
						,new EditSelectOption(id+":run_type:run_type_day",{"descr":"Дневные"})
						,new EditSelectOption(id+":run_type:run_type_night",{"descr":"Ночные"})
					],
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("run_type")
			}),
			"sign":"e"
		}
		,"shift_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":shift_type",{
					"labelCaption":"График:",
					"elements":[
						new EditSelectOption(id+":shift_type:shift_type_all",{"descr":"Все"})
						,new EditSelectOption(id+":shift_type:shift_type_on",{"descr":"По графику"})
						,new EditSelectOption(id+":shift_type:shift_type_off",{"descr":"Вне графика"})
					],
					"contClassName":"form-group-filter"
				}),
				"field":new FieldString("shift_type")
			}),
			"sign":"e"
		}
		,"owner":{
			"binding":new CommandBinding({
				"control":new OwnerEdit(id+":owner",{"contClassName":"form-group-filter"}),
				"field":new FieldString("vehicle_owner_descr")
			}),
			"sign":"e"
		}
		,"feature":{
			"binding":new CommandBinding({
				"control":new FeatureEdit(id+":feature",{"contClassName":"form-group-filter"}),
				"field":new FieldString("vehicle_feature")
			}),
			"sign":"e"
		}
		
		,"vehicle":{
			"binding":new CommandBinding({
				"control":new VehicleEdit(id+":vehicle",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("vehicle_id")
			}),
			"sign":"e"
		}
		
	};

	VehicleEfficiency_View.superclass.constructor.call(this, id, options);
	
}
extend(VehicleEfficiency_View,ViewReport);

