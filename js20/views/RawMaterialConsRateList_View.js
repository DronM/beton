/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function RawMaterialConsRateList_View(id,options){
	options = options || {};	
	options.addElement = function(){
		this.addElement(new RawMaterialConsRateGrid(id+":grid"));
	}
	
	RawMaterialConsRateList_View.superclass.constructor.call(this,id,options);
	
}
extend(RawMaterialConsRateList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

