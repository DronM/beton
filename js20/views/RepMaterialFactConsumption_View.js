/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepMaterialFactConsumption_View(id,options){

	options = options || {};
	
	var contr = new MaterialFactConsumption_Controller();	
	options.publicMethod = contr.getPublicMethod("get_report");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "RepMaterialFactConsumption";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"valueFrom":(options.templateParams)? options.templateParams.date_from:"",
		"valueTo":(options.templateParams)? options.templateParams.date_to:"",
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
		,"production_site":{
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-production_site",{"labelCaption":"Завод:","contClassName":"form-group-filter"}),
				"field":new FieldInt("production_site_id")
			}),
			"sign":"e"
		}
		
	};
	
	RepMaterialFactConsumption_View.superclass.constructor.call(this, id, options);	
}
extend(RepMaterialFactConsumption_View,ViewReport);

