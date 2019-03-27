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
function RAMaterialConsumptionDateList_View(id,options){
	options = options || {};
	console.dir(options.models.RAMaterialConsumptionDateList_Model)	
	options.addElement = function(){
		this.addElement(new RAMaterialConsumptionDateGrid(id+":grid",{
			"model":options.models.RAMaterialConsumptionDateList_Model
			,"modelMat":options.models.RawMaterial_Model
			,"variantStorage":options.variantStorage
		}));
	}
	
	RAMaterialConsumptionDateList_View.superclass.constructor.call(this,id,options);
	
}
extend(RAMaterialConsumptionDateList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

