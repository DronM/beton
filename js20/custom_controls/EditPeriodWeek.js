/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020
 
 * @class
 * @classdesc Period Edit cotrol
 
 * @extends EditPeriodDate
 
 * @requires core/extend.js
 * @requires controls/ControlContainer.js
 * @requires controls/ButtonCmd.js               
 
 * @param string id 
 * @param {object} options
 * @param {object} options.filters
 * @param {string} options.dateFormat  
 * @param {function} options.onChange
 * @param {Date} [options.dateFrom=first date of current month]   
 */
 
function EditPeriodWeek(id,options){
	options = options || {};	
	
	options.downTitle = "Предыдущая неделя";
	options.upTitle = "Следующая неделя";
	
	EditPeriodWeek.superclass.constructor.call(this,id,options);
}
extend(EditPeriodWeek,EditPeriodMonth);

EditPeriodWeek.prototype.getDefaulDateFrom = function(){
	return DateHelper.weekStart();
}

EditPeriodWeek.prototype.go = function(sign){
	var t = (sign>0)?  this.m_dateTo.getTime() : this.m_dateFrom.getTime();
	this.setDateFrom(DateHelper.weekStart( new Date(t + sign*24*60*60*1000)) );
}

EditPeriodWeek.prototype.calcDateTo = function(){	
	this.m_dateTo = DateHelper.weekEnd(this.m_dateFrom);
}

EditPeriodWeek.prototype.getPeriodDescr = function(){	
	return (DateHelper.format(this.m_dateFrom,"d FF")+" (Пн.) - "+DateHelper.format(this.m_dateTo,"d FF")+" (Вс.)");
}


