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
 
function EditPeriodMonth(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("EditPeriodMonth");
	
	options.cmdPeriodSelect = false;
	options.downTitle = "Предыдущий месяц";
	options.upTitle = "Следующий месяц";
	options.cmdControlTo = false;
	options.cmdControlFrom = false;
	
	options.cmdDownFast = false;
	options.cmdUpFast = false;
	
	options.periodSelectClass = PeriodSelectBeton;
	options.periodSelectOptions = {"periodShift":true};
	
	this.m_dateFrom = options.dateFrom;	
	this.calcDateTo();
	
	this.m_filters = options.filters;	
	this.m_dateFormat = options.dateFormat;
	this.m_onChange = options.onChange;
	
	EditPeriodMonth.superclass.constructor.call(this,id,options);
}
extend(EditPeriodMonth,EditPeriodDate);

EditPeriodMonth.prototype.m_dateFrom;
EditPeriodMonth.prototype.m_dateTo;
EditPeriodMonth.prototype.m_timeFrom;
EditPeriodMonth.prototype.shiftLengthMS;

EditPeriodMonth.prototype.addControls = function(){

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

EditPeriodMonth.prototype.picCustomDate = function(){
	var self = this;
	var p = $(this.getElement("inf").getNode());
	p.datepicker({
		format:{
			//called after date is selected
			toDisplay: function (date, format, language) {
				self.setDateFrom(new Date(date.getTime()));
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

EditPeriodMonth.prototype.go = function(sign){
	var t = (sign>0)?  this.m_dateTo.getTime() : this.m_dateFrom.getTime();
	this.setDateFrom(DateHelper.monthStart( new Date(t + sign*24*60*60*1000)) );
}

EditPeriodMonth.prototype.setDateFrom = function(dt){
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
EditPeriodMonth.prototype.getDateFrom = function(){
	return this.m_dateFrom;
}

EditPeriodMonth.prototype.calcDateTo = function(){	
	this.m_dateTo = DateHelper.monthEnd(this.m_dateFrom);
}

EditPeriodMonth.prototype.updateDateInf = function(){	
	this.getElement("inf").setValue(this.getPeriodDescr());
}

EditPeriodMonth.prototype.getPeriodDescr = function(){	
	return (DateHelper.format(this.m_dateFrom,"FF Y"));
}

EditPeriodMonth.prototype.applyFilter = function(v){
	if(this.m_filters&&this.m_filters.length){
		this.m_filters[0].val = DateHelper.format(this.m_dateFrom,this.m_dateFormat);
		if(this.m_filters.length>1){
			this.m_filters[1].val = DateHelper.format(this.m_dateTo,this.m_dateFormat);
		}
	}
}

EditPeriodMonth.prototype.setGrid = function(v){
	this.m_grid = v;
	if(this.m_filters&&this.m_filters.length){
		this.applyFilter();
		
		for (var i=0;i<this.m_filters.length;i++){
			this.m_grid.setFilter(this.m_filters[i]);
		}
		
	}
}
