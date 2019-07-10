/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2019

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ShipmentPumpForVehOwnerCmdSetAgreed(id,options){
	options = options || {};	

	ShipmentPumpForVehOwnerCmdSetAgreed.superclass.constructor.call(this,id,options);
		
}
extend(ShipmentPumpForVehOwnerCmdSetAgreed,ShipmentForVehOwnerCmdSetAgreed);

/* Constants */
ShipmentPumpForVehOwnerCmdSetAgreed.prototype.METHOD_ID = "owner_set_pump_agreed_all";

/* private members */

/* protected*/


/* public methods */

