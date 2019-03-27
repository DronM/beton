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

	this.PERIOD_ALIASES = ["all",(options.periodShift? "shift":"day"),"week","month","quarter","year"];
	this.PERIODS = ["Произвольный период",(options.periodShift? "Текущая смена":"Текущий день"),"Текущая неделя","Текущий месяц","Текущий квартал","Текущий год"];
	
	PeriodSelectBeton.superclass.constructor.call(this,id,options);
	
}
extend(PeriodSelectBeton,PeriodSelect);

/* Constants */

/* private members */

/* protected*/


/* public methods */
