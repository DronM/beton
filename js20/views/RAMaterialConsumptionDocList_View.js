/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function RAMaterialConsumptionDocList_View(id,options){
	options = options || {};
	options.addElement = function(){
		this.addElement(new RAMaterialConsumptionDocGrid(id+":grid",{
			"model":(options.models&&options.models.RAMaterialConsumptionDocList_Model)? options.models.RAMaterialConsumptionDocList_Model:new ModelXML("RAMaterialConsumptionDocList_Model")
			,"modelMat":(options.models&& options.models.RawMaterial_Model)? options.models.RawMaterial_Model : new RawMaterial_Model()
			,"variantStorage":options.variantStorage
		}));
	}
	
	RAMaterialConsumptionDocList_View.superclass.constructor.call(this,id,options);
	
}
extend(RAMaterialConsumptionDocList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

