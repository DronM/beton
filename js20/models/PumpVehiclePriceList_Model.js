/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelJSON
 
 * @requires core/extend.js
 * @requires core/ModelJSON.js
 
 * @param {string} id 
 * @param {Object} options
 */

function PumpVehiclePriceList_Model(options){
	var id = 'PumpVehiclePriceList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.dt_from = new FieldDateTime("dt_from",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pump_price = new FieldJSONB("pump_price",filed_options);
	
		PumpVehiclePriceList_Model.superclass.constructor.call(this,id,options);
}
extend(PumpVehiclePriceList_Model,ModelJSON);

