/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function LabEntryAvgReport_View(id,options){

	options = options || {};
	
	var contr = new LabEntry_Controller();	
	options.publicMethod = contr.getPublicMethod("lab_avg_report");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "LabAvgValsReport";
	
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
					"labelCaption":"Дней для средних значений:",
					"value":"2"
				}),
				"field":new FieldInt("cnt")
			}),
			"sign":"e"
		}
		,"report_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-report_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Показатель:",
					"elements":[
						new EditSelectOption(id+":filter-ctrl-report_type:table",{
							"descr":"Таблица","value":"table","checked":true
						})
						,new EditSelectOption(id+":filter-ctrl-report_type:chart",{
							"descr":"График","value":"chart","checked":false
						})						
					]
				}),
				"field":new FieldString("report_type")
			}),
			"sign":"e"
		}
		
	};

	//concrete_types
	if(!window.getApp().m_concreteTypesForLabList_Model){
		(new ConcreteType_Controller()).getPublicMethod("get_list_for_lab").run({
			"async":false,
			"ok":function(resp){
				window.getApp().m_concreteTypesForLabList_Model = resp.getModel("ConcreteType_Model");
			}
		})
	}
	var m = window.getApp().m_concreteTypesForLabList_Model;
	if(m){
		while (m.getNextRow()){
			var concr_id = m.getFieldValue("id");
			var concr_name = m.getFieldValue("name");
			options.filters["concrete_type_id_"+concr_id] ={
				"binding":new CommandBinding({
					"control":new EditCheckBox(id+":filter-ctrl-concr_"+concr_id,{
						"labelClassName":"control-label col-lg-4",
						"contClassName":"form-group-filter",
						"labelCaption":concr_name
					}),
					"field":new FieldBool("concrete_type_id_"+concr_id)
				}),
				"sign":"in"
			}; 
		}
	}		
	LabEntryAvgReport_View.superclass.constructor.call(this, id, options);
	
}
extend(LabEntryAvgReport_View,ViewReport);

