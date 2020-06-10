/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepMaterialConsToleranceViolation_View(id,options){

	options = options || {};
	
	var contr = new RawMaterial_Controller();	
	options.publicMethod = contr.getPublicMethod("get_material_cons_tolerance_violation_list");
	options.retContentType = "xml";
	options.reportControl = new Control(id+":report","DIV",{
		"visible":false
		,"template":window.getApp().getTemplate("RepMaterialConsToleranceViolationGrid")
	});
	options.reportViewId = "ViewXML";
	options.templateId = null;
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDateTime(id+":filter-ctrl-period",{
		"valueFrom":(options.templateParams)? options.templateParams.date_from:DateHelper.getStartOfShift(DateHelper.time()),
		"valueTo":(options.templateParams)? options.templateParams.date_to:DateHelper.getEndOfShift(DateHelper.time()),
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
	};

	RepMaterialConsToleranceViolation_View.superclass.constructor.call(this, id, options);
	
}
extend(RepMaterialConsToleranceViolation_View,ViewReport);

RepMaterialConsToleranceViolation_View.prototype.onGetReportData = function(resp){
	var m = resp.getModel("MaterialConsToleranceViolationList_Model");
	
	var ctrl = this.getReportControl();
	ctrl.m_templateOptions = {
		"materials":[],
		"dates":[]
	}
	
	var materials = [];
	var prev_date_time,date_time,material_id;
	while(m.getNextRow()){
		material_id = m.getFieldValue("material_id");
		if(CommonHelper.inArray(material_id,materials)==-1){
			ctrl.m_templateOptions.materials.push({
				"material_descr":m.getFieldValue("materials_ref").getDescr()
				,"material_id":m.getFieldValue("materials_ref").getKey()
			});
			materials.push(material_id);
		}
	}
	
	m.reset();
	var d_ind = -1,m_ind = 0,material_id;
	while(m.getNextRow()){
	
		date_time = m.getFieldValue("date_time");
		if(!prev_date_time || date_time.getTime()!=prev_date_time.getTime()){
			ctrl.m_templateOptions.dates.push({
				"date_descr":DateHelper.format(date_time,"d/m/y")
				,"materials":[]
			});
			d_ind++;
			for(var m_id in ctrl.m_templateOptions.materials){
				ctrl.m_templateOptions.dates[d_ind].materials.push({
					"material_id":ctrl.m_templateOptions.materials[m_id].material_id
					,"norm_quant":0
					,"fact_quant":0
					,"diff_quant":0
					,"diff_percent":0
				});
			}			
			m_ind = 0;
			prev_date_time = date_time;
		}
		
		
		material_id = m.getFieldValue("material_id");		
		while(ctrl.m_templateOptions.dates[d_ind].materials[m_ind].material_id!=material_id){
			m_ind++;
		}
		
		ctrl.m_templateOptions.dates[d_ind].materials[m_ind].norm_quant = m.getFieldValue("norm_quant");
		ctrl.m_templateOptions.dates[d_ind].materials[m_ind].fact_quant = m.getFieldValue("fact_quant");
		ctrl.m_templateOptions.dates[d_ind].materials[m_ind].diff_quant = m.getFieldValue("diff_quant");
		ctrl.m_templateOptions.dates[d_ind].materials[m_ind].diff_percent = m.getFieldValue("diff_percent");
		
	}
	console.log(ctrl.m_templateOptions)
	ctrl.updateHTML();
	ctrl.setVisible(true);
}

