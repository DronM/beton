/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function LabEntryItemOnRatePeriodReport_View(id,options){

	options = options || {};
	
	var contr = new LabEntry_Controller();	
	options.publicMethod = contr.getPublicMethod("item_on_rate_period_report");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "LabItemReport";
	
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
		,"item_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-item_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Показатель:",
					"elements":[
						new EditSelectOption(id+":filter-ctrl-item_type:ok",{
							"descr":"ОК","value":"ok","checked":true
						})
						,new EditSelectOption(id+":filter-ctrl-item_type:weight",{
							"descr":"Вес","value":"weight","checked":false
						})						
						,new EditSelectOption(id+":filter-ctrl-item_type:p7",{
							"descr":"p7","value":"p7","checked":false
						})						
						,new EditSelectOption(id+":filter-ctrl-item_type:p28",{
							"descr":"p28","value":"p28","checked":false
						})						
						,new EditSelectOption(id+":filter-ctrl-item_type:cnt",{
							"descr":"Кол-во","value":"cnt","checked":false
						})						
						
					]
				}),
				"field":new FieldString("item_type")
			}),
			"sign":"e"
		}
		
		,"cnt":{
			"binding":new CommandBinding({
				"control":new EditInt(id+":filter-ctrl-cnt",{
					"contClassName":"form-group-filter",
					"labelCaption":"Минимальное кол-во значений:",
					"value":"10"
				}),
				"field":new FieldInt("cnt")
			}),
			"sign":"e"
		}
	};

	LabEntryItemOnRatePeriodReport_View.superclass.constructor.call(this, id, options);
	
}
extend(LabEntryItemOnRatePeriodReport_View,ViewReport);

