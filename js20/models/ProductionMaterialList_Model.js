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

function ProductionMaterialList_Model(options){
	var id = 'ProductionMaterialList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.production_site_id = new FieldInt("production_site_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Номер производства Elkon';
	filed_options.autoInc = false;	
	
	options.fields.production_id = new FieldInt("production_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Завод';
	filed_options.autoInc = false;	
	
	options.fields.production_sites_ref = new FieldJSON("production_sites_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.shipment_id = new FieldInt("shipment_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.shipments_ref = new FieldJSON("shipments_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Материал';
	filed_options.autoInc = false;	
	
	options.fields.materials_ref = new FieldJSON("materials_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.material_id = new FieldInt("material_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Силос';
	filed_options.autoInc = false;	
	
	options.fields.cement_silos_ref = new FieldJSON("cement_silos_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cement_silo_id = new FieldInt("cement_silo_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество по подбору';
	filed_options.autoInc = false;	
	
	options.fields.quant_consuption = new FieldFloat("quant_consuption",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество факт';
	filed_options.autoInc = false;	
	
	options.fields.quant_fact = new FieldFloat("quant_fact",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество факт треб.';
	filed_options.autoInc = false;	
	
	options.fields.quant_fact_req = new FieldFloat("quant_fact_req",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество испр.вручную';
	filed_options.autoInc = false;	
	
	options.fields.quant_corrected = new FieldFloat("quant_corrected",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Идентификатор исправления Elkon';
	filed_options.autoInc = false;	
	
	options.fields.elkon_correction_id = new FieldString("elkon_correction_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Кто исправил';
	filed_options.autoInc = false;	
	
	options.fields.correction_users_ref = new FieldJSON("correction_users_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Когда исправил';
	filed_options.autoInc = false;	
	
	options.fields.correction_date_time_set = new FieldDateTime("correction_date_time_set",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Разница';
	filed_options.autoInc = false;	
	
	options.fields.quant_dif = new FieldFloat("quant_dif",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.material_quant = new FieldFloat("material_quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Превышение';
	filed_options.autoInc = false;	
	
	options.fields.dif_violation = new FieldBool("dif_violation",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Идентификатор строки фактического расхода';
	filed_options.autoInc = false;	
	
	options.fields.material_fact_consumption_id = new FieldInt("material_fact_consumption_id",filed_options);
	
		ProductionMaterialList_Model.superclass.constructor.call(this,id,options);
}
extend(ProductionMaterialList_Model,ModelXML);

