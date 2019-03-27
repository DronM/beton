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

function RawMaterialConsRate_Model(options){
	var id = 'RawMaterialConsRate_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.rate_date_id = new FieldInt("rate_date_id",filed_options);
	options.fields.rate_date_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Марка бетона';
	filed_options.autoInc = false;	
	
	options.fields.concrete_type_id = new FieldInt("concrete_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Материал';
	filed_options.autoInc = false;	
	
	options.fields.raw_material_id = new FieldInt("raw_material_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Расход';
	filed_options.autoInc = false;	
	
	options.fields.rate = new FieldFloat("rate",filed_options);
	options.fields.rate.getValidator().setMaxLength('19');
	
		RawMaterialConsRate_Model.superclass.constructor.call(this,id,options);
}
extend(RawMaterialConsRate_Model,ModelXML);

