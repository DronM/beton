/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017,2019

 * @extends Control
 * @requires core/extend.js
 * @requires Control.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {bool} options.periodShift 
 */
function PeriodSelectBeton(id,options){
	options = options || {};	

	if(options.periodShift){
		this.PERIOD_ALIASES = ["all","shift","prev_shift","week","month","quarter","year"];
		this.PERIODS = ["Произвольный период","Текущая смена","Предыдущая смена","Текущая неделя","Текущий месяц","Текущий квартал","Текущий год"];
	}
	else{
		this.PERIOD_ALIASES = ["all","day","week","month","quarter","year"];
		this.PERIODS = ["Произвольный период","Текущий день","Текущая неделя","Текущий месяц","Текущий квартал","Текущий год"];
	}
	
	PeriodSelectBeton.superclass.constructor.call(this,id,options);
	
}
extend(PeriodSelectBeton,PeriodSelect);

/* Constants */

/* private members */

/* protected*/


/* public methods */
