/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXML
 
 * @requires core/extend.js
 * @requires core/ModelXML.js
 
 * @param {string} id 
 * @param {Object} options
 */

function RAMaterialConsumptionDocList_Model(options){
	var id = 'RAMaterialConsumptionDocList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Дата';
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTime("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_descr = new FieldString("date_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Марка';
	filed_options.autoInc = false;	
	
	options.fields.concrete_type_descr = new FieldString("concrete_type_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ТС';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_descr = new FieldString("vehicle_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Водитель';
	filed_options.autoInc = false;	
	
	options.fields.driver_descr = new FieldString("driver_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объем';
	filed_options.autoInc = false;	
	
	options.fields.concrete_quant = new FieldFloat("concrete_quant",filed_options);
	
		RAMaterialConsumptionDocList_Model.superclass.constructor.call(this,id,options);
}
extend(RAMaterialConsumptionDocList_Model,ModelXML);

