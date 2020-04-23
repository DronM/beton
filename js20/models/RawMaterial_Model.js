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

function RawMaterial_Model(options){
	var id = 'RawMaterial_Model';
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
	filed_options.alias = 'Плановый приход';
	filed_options.autoInc = false;	
	
	options.fields.planned_procurement = new FieldFloat("planned_procurement",filed_options);
	options.fields.planned_procurement.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дней завоза';
	filed_options.autoInc = false;	
	
	options.fields.supply_days_count = new FieldInt("supply_days_count",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.concrete_part = new FieldBool("concrete_part",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.ord = new FieldInt("ord",filed_options);
	options.fields.ord.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объем ТС завоза';
	filed_options.autoInc = false;	
	
	options.fields.supply_volume = new FieldInt("supply_volume",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.store_days = new FieldInt("store_days",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.min_end_quant = new FieldFloat("min_end_quant",filed_options);
	options.fields.min_end_quant.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.max_required_quant_tolerance_percent = new FieldFloat("max_required_quant_tolerance_percent",filed_options);
	options.fields.max_required_quant_tolerance_percent.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.max_fact_quant_tolerance_percent = new FieldFloat("max_fact_quant_tolerance_percent",filed_options);
	options.fields.max_fact_quant_tolerance_percent.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Цемент,учет в силосе';
	filed_options.autoInc = false;	
	
	options.fields.is_cement = new FieldBool("is_cement",filed_options);
	
			
			
			
		RawMaterial_Model.superclass.constructor.call(this,id,options);
}
extend(RawMaterial_Model,ModelXML);

