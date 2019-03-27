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

function ShipmentTimeList_Model(options){
	var id = 'ShipmentTimeList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = '№';
	filed_options.autoInc = false;	
	
	options.fields.id = new FieldString("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Код клиента';
	filed_options.autoInc = false;	
	
	options.fields.client_id = new FieldInt("client_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Клиент';
	filed_options.autoInc = false;	
	
	options.fields.client_descr = new FieldString("client_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Код объекта';
	filed_options.autoInc = false;	
	
	options.fields.destination_id = new FieldInt("destination_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объект';
	filed_options.autoInc = false;	
	
	options.fields.destination_descr = new FieldString("destination_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Код завода';
	filed_options.autoInc = false;	
	
	options.fields.production_site_id = new FieldInt("production_site_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Завод';
	filed_options.autoInc = false;	
	
	options.fields.production_site_descr = new FieldString("production_site_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объем';
	filed_options.autoInc = false;	
	
	options.fields.quant = new FieldFloat("quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер ТС';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_descr = new FieldString("vehicle_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ТС';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_id = new FieldInt("vehicle_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Водитель код';
	filed_options.autoInc = false;	
	
	options.fields.driver_id = new FieldInt("driver_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Водитель';
	filed_options.autoInc = false;	
	
	options.fields.driver_descr = new FieldString("driver_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Назначение';
	filed_options.autoInc = false;	
	
	options.fields.assign_date_time = new FieldDateTime("assign_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Назначение';
	filed_options.autoInc = false;	
	
	options.fields.assign_date_time_descr = new FieldString("assign_date_time_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.ship_date_time = new FieldDateTime("ship_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.ship_date_time_descr = new FieldString("ship_date_time_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Опоздание диспетчара (мин)';
	filed_options.autoInc = false;	
	
	options.fields.dispatcher_fail_min = new FieldInt("dispatcher_fail_min",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Норма погрузки (мин)';
	filed_options.autoInc = false;	
	
	options.fields.ship_time_norm = new FieldInt("ship_time_norm",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Опоздание оператора (мин)';
	filed_options.autoInc = false;	
	
	options.fields.operator_fail_min = new FieldInt("operator_fail_min",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Опоздание общее (мин)';
	filed_options.autoInc = false;	
	
	options.fields.total_fail_min = new FieldInt("total_fail_min",filed_options);
	
		ShipmentTimeList_Model.superclass.constructor.call(this,id,options);
}
extend(ShipmentTimeList_Model,ModelXML);

