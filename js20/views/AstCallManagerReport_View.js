/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function AstCallManagerReport_View(id,options){

	options = options || {};
	
	var contr = new AstCall_Controller();	
	options.publicMethod = contr.getPublicMethod("manager_report");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "AstCallReport";
	
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
		,"user":{
			"binding":new CommandBinding({
				"control":new UserEditRef(id+":filter-ctrl-user",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("user_id")
			}),
			"sign":"e"
		}
	};

	AstCallManagerReport_View.superclass.constructor.call(this, id, options);
	
}
extend(AstCallManagerReport_View,ViewReport);

