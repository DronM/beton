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
function DOCMaterialProcurementShiftList_View(id,options){
	options = options || {};	
	options.addElement = function(){
		this.addElement(new DOCMaterialProcurementShiftGrid(id+":grid",{
			"model":options.models.DOCMaterialProcurementShiftList_Model
			,"modelMat":options.models.RawMaterial_Model
			,"variantStorage":options.variantStorage
		}));
	}
	
	DOCMaterialProcurementShiftList_View.superclass.constructor.call(this,id,options);
	
}
extend(DOCMaterialProcurementShiftList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

