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

function MaterialStoreForOrderList_Model(options){
	var id = 'MaterialStoreForOrderList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	options.fields.id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.production_sites_ref = new FieldJSON("production_sites_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setRequired(true);
	options.fields.name.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.load_capacity = new FieldFloat("load_capacity",filed_options);
	options.fields.load_capacity.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.balance = new FieldFloat("balance",filed_options);
	options.fields.balance.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.material_id = new FieldInt("material_id",filed_options);
	
		MaterialStoreForOrderList_Model.superclass.constructor.call(this,id,options);
}
extend(MaterialStoreForOrderList_Model,ModelXML);

