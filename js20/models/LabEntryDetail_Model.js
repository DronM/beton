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

function LabEntryDetail_Model(options){
	var id = 'LabEntryDetail_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id_key = new FieldInt("id_key",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Код';
	filed_options.autoInc = false;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.shipment_id = new FieldInt("shipment_id",filed_options);
	options.fields.shipment_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ОК';
	filed_options.autoInc = false;	
	
	options.fields.ok = new FieldInt("ok",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Масса';
	filed_options.autoInc = false;	
	
	options.fields.weight = new FieldInt("weight",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'КН';
	filed_options.autoInc = false;	
	
	options.fields.kn = new FieldInt("kn",filed_options);
	
			
		LabEntryDetail_Model.superclass.constructor.call(this,id,options);
}
extend(LabEntryDetail_Model,ModelXML);

