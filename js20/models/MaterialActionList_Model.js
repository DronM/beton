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

function MaterialActionList_Model(options){
	var id = 'MaterialActionList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.is_cement = new FieldBool("is_cement",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Материал';
	filed_options.autoInc = false;	
	
	options.fields.material_name = new FieldString("material_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Начальный остаток';
	filed_options.autoInc = false;	
	
	options.fields.quant_start = new FieldFloat("quant_start",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Приход';
	filed_options.autoInc = false;	
	
	options.fields.quant_deb = new FieldFloat("quant_deb",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Расход';
	filed_options.autoInc = false;	
	
	options.fields.quant_kred = new FieldFloat("quant_kred",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Корректировка';
	filed_options.autoInc = false;	
	
	options.fields.quant_correction = new FieldFloat("quant_correction",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Конечный остаток';
	filed_options.autoInc = false;	
	
	options.fields.quant_end = new FieldFloat("quant_end",filed_options);
	
		MaterialActionList_Model.superclass.constructor.call(this,id,options);
}
extend(MaterialActionList_Model,ModelXML);

