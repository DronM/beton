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

function LabEntry_Model(options){
	var id = 'LabEntry_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.shipment_id = new FieldInt("shipment_id",filed_options);
	options.fields.shipment_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Подборы';
	filed_options.autoInc = false;	
	
	options.fields.samples = new FieldText("samples",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Материалы';
	filed_options.autoInc = false;	
	
	options.fields.materials = new FieldText("materials",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'OK2';
	filed_options.autoInc = false;	
	
	options.fields.ok2 = new FieldText("ok2",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Время';
	filed_options.autoInc = false;	
	
	options.fields.time = new FieldText("time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Подбор';
	filed_options.autoInc = false;	
	
	options.fields.rate_date_id = new FieldInt("rate_date_id",filed_options);
	
			
		LabEntry_Model.superclass.constructor.call(this,id,options);
}
extend(LabEntry_Model,ModelXML);

