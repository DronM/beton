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

function DOCMaterialProcurement_Model(options){
	var id = 'DOCMaterialProcurement_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата';
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTime("date_time",filed_options);
	options.fields.date_time.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер';
	filed_options.autoInc = false;	
	
	options.fields.number = new FieldString("number",filed_options);
	options.fields.number.getValidator().setMaxLength('11');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.doc_ref = new FieldString("doc_ref",filed_options);
	options.fields.doc_ref.getValidator().setMaxLength('36');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Проведен';
	filed_options.autoInc = false;	
	
	options.fields.processed = new FieldBool("processed",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Автор';
	filed_options.autoInc = false;	
	
	options.fields.user_id = new FieldInt("user_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Поставщик';
	filed_options.autoInc = false;	
	
	options.fields.supplier_id = new FieldInt("supplier_id",filed_options);
	options.fields.supplier_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Перевозчик';
	filed_options.autoInc = false;	
	
	options.fields.carrier_id = new FieldInt("carrier_id",filed_options);
	options.fields.carrier_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Водитель';
	filed_options.autoInc = false;	
	
	options.fields.driver = new FieldString("driver",filed_options);
	options.fields.driver.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'гос.номер';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_plate = new FieldString("vehicle_plate",filed_options);
	options.fields.vehicle_plate.getValidator().setMaxLength('10');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Материал';
	filed_options.autoInc = false;	
	
	options.fields.material_id = new FieldInt("material_id",filed_options);
	options.fields.material_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Брутто';
	filed_options.autoInc = false;	
	
	options.fields.quant_gross = new FieldFloat("quant_gross",filed_options);
	options.fields.quant_gross.getValidator().setMaxLength('19');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Нетто';
	filed_options.autoInc = false;	
	
	options.fields.quant_net = new FieldFloat("quant_net",filed_options);
	options.fields.quant_net.getValidator().setMaxLength('19');
	
			
			
			
			
			
				
			
		DOCMaterialProcurement_Model.superclass.constructor.call(this,id,options);
}
extend(DOCMaterialProcurement_Model,ModelXML);

