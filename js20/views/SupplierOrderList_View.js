/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function SupplierOrderList_View(id,options){

	options = options || {};
	
	options.publicMethod = (new RawMaterial_Controller()).getPublicMethod("supplier_orders_list");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "SupplierOrderList";
	
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
		"field":new FieldDateTime("shift")
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
		,"material":{
			"binding":new CommandBinding({
				"control":new MaterialSelect(id+":material",{
					"contClassName":"form-group-filter",
					"forConcrete":true
				}),
				"field":new FieldInt("material_id")
			}),
			"sign":"e"
		}
	};

	SupplierOrderList_View.superclass.constructor.call(this, id, options);
	
}
extend(SupplierOrderList_View,ViewReport);

