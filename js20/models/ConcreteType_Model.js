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

function ConcreteType_Model(options){
	var id = 'ConcreteType_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Наименование';
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setRequired(true);
	options.fields.name.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Код 1С';
	filed_options.autoInc = false;	
	
	options.fields.code_1c = new FieldString("code_1c",filed_options);
	options.fields.code_1c.getValidator().setRequired(true);
	options.fields.code_1c.getValidator().setMaxLength('11');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Норма давл.';
	filed_options.autoInc = false;	
	
	options.fields.pres_norm = new FieldFloat("pres_norm",filed_options);
	options.fields.pres_norm.getValidator().setRequired(true);
	options.fields.pres_norm.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Кф.МПА';
	filed_options.autoInc = false;	
	
	options.fields.mpa_ratio = new FieldFloat("mpa_ratio",filed_options);
	options.fields.mpa_ratio.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Цена';
	filed_options.autoInc = false;	
	
	options.fields.price = new FieldFloat("price",filed_options);
	options.fields.price.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Есть нормы расхода';
	filed_options.autoInc = false;	
	
	options.fields.material_cons_rates = new FieldBool("material_cons_rates",filed_options);
	
			
		ConcreteType_Model.superclass.constructor.call(this,id,options);
}
extend(ConcreteType_Model,ModelXML);

