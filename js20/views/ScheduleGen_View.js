/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends View
 * @requires core/extend.js
 * @requires controls/View.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ScheduleGen_View(id,options){
	options = options || {};	
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.HEAD_TITLE = "Формирование графиков работы";
	
	var self = this;
	options.addElement = function(){
		this.addElement(new EditPeriodDate(id+":period",{
			"valueFrom":DateHelper.time(),
			"valueTo":DateHelper.time()
		}));
		
		var day_cl = "control-label "+window.getBsCol(3);
		var ctrl_cl = "input-group "+window.getBsCol(1);
		
		this.addElement(new VehicleDriverForSchedGenGrid(id+":vehicle_list"));
		
		this.addElement(new EditCheckBox(id+":day1",{		
			"labelCaption":"Понедельник",			
			"labelClassName":day_cl,
			"editContClassName":ctrl_cl,
			"checked":true
		}));
		this.addElement(new EditCheckBox(id+":day2",{		
			"labelCaption":"Вторник",
			"labelClassName":day_cl,
			"editContClassName":ctrl_cl,
			"checked":true
			}));
		this.addElement(new EditCheckBox(id+":day3",{		
			"labelCaption":"Среда",
			"labelClassName":day_cl,
			"editContClassName":ctrl_cl,
			"checked":true
		}));
		this.addElement(new EditCheckBox(id+":day4",{		
			"labelCaption":"Четверг",
			"labelClassName":day_cl,
			"checked":true
		}));
		this.addElement(new EditCheckBox(id+":day5",{		
			"labelClassName":day_cl,
			"editContClassName":ctrl_cl,
			"labelCaption":"Пятница",
			"checked":true
		}));
		this.addElement(new EditCheckBox(id+":day6",{		
			"labelClassName":day_cl,
			"labelCaption":"Суббота"
		}));
		this.addElement(new EditCheckBox(id+":day7",{		
			"labelClassName":day_cl,
			"editContClassName":ctrl_cl,
			"labelCaption":"Воскресенье"
		}));
		
		this.addElement(new ButtonCmd(id+":btnOk",{
			"caption":"Сформировать",
			"onClick":function(){
				self.process();
			},
			"title":"Сформировать расписание по заданным ТС"
		
		}));
		
		this.addElement(new Control(id+":report","DIV"));
	}
	
	ScheduleGen_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ScheduleGen_View,View);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ScheduleGen_View.prototype.process = function(){
	var pm = (new VehicleSchedule_Controller()).getPublicMethod("gen_schedule");
	pm.setFieldValue("date_from",this.getElement("period").getControlFrom().getValue());
	pm.setFieldValue("date_to",this.getElement("period").getControlTo().getValue());
	
	//pm.setFieldValue("vehicle_id",this.getElement("vehicle").getValue().getKey());
	//pm.setFieldValue("driver_id",this.getElement("driver").getValue().getKey());
	
	pm.setFieldValue("vehicle_list",this.getElement("vehicle_list").serialize());
	
	pm.setFieldValue("day1",this.getElement("day1").getValue());
	pm.setFieldValue("day2",this.getElement("day2").getValue());
	pm.setFieldValue("day3",this.getElement("day3").getValue());
	pm.setFieldValue("day4",this.getElement("day4").getValue());
	pm.setFieldValue("day5",this.getElement("day5").getValue());
	pm.setFieldValue("day6",this.getElement("day6").getValue());
	pm.setFieldValue("day7",this.getElement("day7").getValue());
	
	window.setGlobalWait(true);
	var self = this;
	pm.run({
		"viewId":"VehicleScheduleReport",
		"retContentType":"text",
		"ok":function(respText){
			self.getElement("report").m_node.innerHTML = respText;
		
		},
		"all":function(){
			window.setGlobalWait(false);
		}
	});
}
