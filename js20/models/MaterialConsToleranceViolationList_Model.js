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

function MaterialConsToleranceViolationList_Model(options){
	var id = 'MaterialConsToleranceViolationList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTime("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.material_id = new FieldInt("material_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Материал';
	filed_options.autoInc = false;	
	
	options.fields.materials_ref = new FieldJSON("materials_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Расход нормативный';
	filed_options.autoInc = false;	
	
	options.fields.norm_quant = new FieldFloat("norm_quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Расход фактический';
	filed_options.autoInc = false;	
	
	options.fields.fact_quant = new FieldFloat("fact_quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отклонение (факт-норм)';
	filed_options.autoInc = false;	
	
	options.fields.diff_quant = new FieldFloat("diff_quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отклонение, %';
	filed_options.autoInc = false;	
	
	options.fields.diff_percent = new FieldFloat("diff_percent",filed_options);
	
		MaterialConsToleranceViolationList_Model.superclass.constructor.call(this,id,options);
}
extend(MaterialConsToleranceViolationList_Model,ModelXML);

