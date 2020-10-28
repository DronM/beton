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
	//options.reportViewId = "ViewHTMLXSLT";
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

LabEntryAvgReport_View.prototype.getReportType = function(){	
	return this.m_commands.getCmdFilter().getFilter().getFilter("report_type").binding.getControl().getValue();
}

LabEntryAvgReport_View.prototype.onReport = function(){	

	var is_chart = (this.getReportType()=="chart");
	this.setReportViewId(is_chart? "ViewXML":"ViewHTMLXSLT");
	this.m_retContentType = is_chart? "xml":"text";
	if(window["lab_avg_report"]){
		window["lab_avg_report"] = undefined;
	}
	LabEntryAvgReport_View.superclass.onReport.call(this);
}

/**
 * respData text | xml
 */
LabEntryAvgReport_View.prototype.onGetReportData = function(respData){
	
	if(this.getReportType()=="chart"){
		//chart
		var m = respData.getModel("lab_avg_report");
		
		var chart_data = {
			"dates":[],
			"concrete_types":{},
			"data_sets":[]
		}
		
		var d,ct_id;
		while(m.getNextRow()){
			d = m.getFieldValue("date_descr");
			
			if(CommonHelper.inArray(d,chart_data.dates)<0){
				chart_data.dates.push(d);
			}
			ct_id = "ct_"+m.getFieldValue("concrete_type_id");
			
			if(!chart_data.concrete_types[ct_id]){
				chart_data.concrete_types[ct_id] = {
					"descr":m.getFieldValue("concrete_type_descr")
					,"vals":{}
				};
			}
			chart_data.concrete_types[ct_id].vals[d] = m.getFieldValue("val");
		}
		chart_data.dates.sort();
		var v;
		var ct_ind=0;
		var color,red_v=255,gr_v =99;
		chart_data.data_sets = [];
		for(var ct_id in chart_data.concrete_types){			
			var date_vals = [];			
			for(var i=0;i<chart_data.dates.length;i++){
				date_vals.push(chart_data.concrete_types[ct_id].vals[chart_data.dates[i]]);				
			}
			color = 'rgb('+red_v+', '+gr_v+', 132)';
			chart_data.data_sets.push({
				"label": "Показатели "+chart_data.concrete_types[ct_id].descr,
			    	"data":date_vals,
			    	"backgroundColor":color,
			 	"borderColor":color,
			 	//"borderDash":[5, 5],
			   	"borderWidth":1,
			   	"fill":false
			});
			
			red_v-=50;
			if(red_v<0){
				red_v = 0;
			}
			else if(red_v==0){
				gr_v-=5;
			}
			ct_ind++;
		}
		
		//console.log(chart_data)
		
		var canv = document.getElementById("avg_rep_canvas");
		if(canv){
			this.m_reportControl.getNode().removeChild(canv);
		}
		canv = document.createElement("canvas");
		canv.id = "avg_rep_canvas";
		this.m_reportControl.getNode().appendChild(canv);
		canv.height = 150;
		
		this.m_chart = new Chart(canv.getContext("2d"), {
			"type":"line",
			"options": {
				"responsive": true,
				"elements":{
					"point":{
						"radius": 3
						,"pointStyle":"circle"
					}
				},			
				"title": {
					"display": true,
					"text": "Статистика формовки"
				},
				"tooltips": {
					"mode": "index",
					"intersect": false
				},
				"hover": {
					"mode":"nearest",
					"intersect":true
				},
				"scales": {
					"xAxes":[{
						"display": true,
						"scaleLabel":{
							"display":true,
							"labelString":"Даты"
						},
						"gridLines":{
							"color":"rgba(0, 0, 0, 0)",
						}					
					}],
					"yAxes":[{
						"display": true,
						/*"ticks":{
							"min": 0,
			    				"max": 100,
			    				"stepSize":20
						},*/					
						"scaleLabel":{
							"display": true,
							"labelString":"Значение"
						},
						"gridLines":{
							"color":"rgba(0, 0, 0, 0)"
						}										
					}]
				}
			}	    
		});

		var colors = window.getApp().getChartColors();
		this.m_chart.data = {
			"labels":chart_data.dates,
			"datasets":chart_data.data_sets
		};
		this.m_chart.update();		
		
	}
	else{
		//html
		this.m_reportControl.m_node.innerHTML = respData;	
	}
}


