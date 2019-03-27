/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc Period Edit cotrol
 
 * @extends EditPeriodDate
 
 * @requires core/extend.js
 * @requires controls/ControlContainer.js
 * @requires controls/ButtonCmd.js               
 
 * @param string id 
 * @param {namespace} options
 */
 
function EditPeriodShift(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("EditPeriodShift");
	
	options.cmdPeriodSelect = false;
	options.downFastTitle = "Предыдущая неделя";
	options.downTitle = "Предыдущая смена";
	options.upFastTitle = "Следующая неделя";
	options.upTitle = "Следующая смена";
	options.cmdControlTo = false;
	options.cmdControlFrom = false;
	
	options.periodSelectClass = PeriodSelectBeton;
	options.periodSelectOptions = {"periodShift":true};
	
	var constants = {"first_shift_start_time":null,"shift_length_time":null};
	window.getApp().getConstantManager().get(constants);

	this.m_shiftLengthMS = DateHelper.timeToMS(constants.shift_length_time.getValue());
	this.m_shiftStartMS = DateHelper.timeToMS(constants.first_shift_start_time.getValue());	
	
	if(options.dateFrom){
		options.dateFrom = new Date(options.dateFrom.getTime()+this.m_shiftStartMS);
	}
	this.m_dateFrom = DateHelper.getStartOfShift(options.dateFrom);	
	this.calcDateTo();
	
	this.m_daysOfWeek = ['Воскресенье','Понедельник','Вторник','Среда','Четверг','Пятница','Суббота'];
	this.m_dateTempl = "d/m";
	
	this.m_filters = options.filters;	
	this.m_dateFormat = options.dateFormat;
	this.m_onChange = options.onChange;
	
	EditPeriodShift.superclass.constructor.call(this,id,options);
}
extend(EditPeriodShift,EditPeriodDate);

EditPeriodShift.prototype.FAST_GO_SHIFT_CNT = 7;

EditPeriodShift.prototype.m_dateFrom;
EditPeriodShift.prototype.m_dateTo;
EditPeriodShift.prototype.m_timeFrom;
EditPeriodShift.prototype.shiftLengthMS;

EditPeriodShift.prototype.addControls = function(){

	this.addElement(this.m_controlDownFast);
	this.addElement(this.m_controlDown);
	
	var self = this;	
	this.addElement(new Label(this.getId()+":inf",{
		"caption":this.getPeriodDescr(),
		"events":{
			"click":function(){
				self.picCustomDate();
			}
		}
	}));

	this.addElement(this.m_controlUp);
	this.addElement(this.m_controlUpFast);	
}

EditPeriodShift.prototype.picCustomDate = function(){
	var self = this;
	var p = $(this.getElement("inf").getNode());
	p.datepicker({
		format:{
			//called after date is selected
			toDisplay: function (date, format, language) {
				self.setDateFrom(new Date(date.getTime() + self.m_shiftStartMS));
			},
			//called in ctrl edit?
			toValue: function (date, format, language) {
			}																	
		},
		language:"ru",
		daysOfWeekHighlighted:"0,6",
		autoclose:true,
		todayHighlight:true,
		orientation: "bottom right",
		//container:form,
		showOnFocus:false,
		clearBtn:true
	});
	
	p.on('hide', function(ev){
		//self.getEditControl().applyMask();
	});					
	
	p.datepicker("show");
}

EditPeriodShift.prototype.goFast = function(sign){
	this.setDateFrom(new Date(this.m_dateFrom.getTime() + this.m_shiftLengthMS*this.FAST_GO_SHIFT_CNT*sign),true);
}

EditPeriodShift.prototype.go = function(sign){
	this.setDateFrom(new Date(this.m_dateFrom.getTime() + this.m_shiftLengthMS*sign),true);
}

EditPeriodShift.prototype.setDateFrom = function(dt){
	this.m_dateFrom = dt;
	this.calcDateTo();
	this.updateDateInf();
		
	if(this.m_grid){
		this.applyFilter();
		this.m_grid.onRefresh();
	}
	else if(this.m_onChange){
		this.m_onChange(this.m_dateFrom,this.m_dateTo);
	}
}
EditPeriodShift.prototype.getDateFrom = function(){
	return this.m_dateFrom;
}

EditPeriodShift.prototype.calcDateTo = function(){	
	this.m_dateTo = new Date(this.m_dateFrom.getTime() + this.m_shiftLengthMS - 1000);
}

EditPeriodShift.prototype.updateDateInf = function(){	
	this.getElement("inf").setValue(this.getPeriodDescr());
}

EditPeriodShift.prototype.getPeriodDescr = function(){	
	return (
		DateHelper.format(this.m_dateFrom,this.m_dateTempl)+
		" ("+this.m_daysOfWeek[this.m_dateFrom.getDay()]+')'+
		" - "+
		DateHelper.format(this.m_dateTo,this.m_dateTempl)
	);
}

EditPeriodShift.prototype.applyFilter = function(v){
	if(this.m_filters&&this.m_filters.length){
		this.m_filters[0].val = DateHelper.format(this.m_dateFrom,this.m_dateFormat);
		if(this.m_filters.length>1){
			this.m_filters[1].val = DateHelper.format(this.m_dateTo,this.m_dateFormat);
		}
	}
}

EditPeriodShift.prototype.setGrid = function(v){
	this.m_grid = v;
	if(this.m_filters&&this.m_filters.length){
		this.applyFilter();
		
		for (var i=0;i<this.m_filters.length;i++){
			this.m_grid.setFilter(this.m_filters[i]);
		}
		
	}
}
EditPeriodShift.prototype.setPredefinedPeriod = function(per){
	if (per=="shift"){
		this.setCtrlDateTime(this.getControlFrom(),DateHelper.dateStart());
		this.setCtrlDateTime(this.getControlTo(),new Date(DateHelper.dateStart().getTime()+24*60*60*1000));
	}				
	EditPeriodShift.superclass.setPredefinedPeriod.call(this,per);
}

