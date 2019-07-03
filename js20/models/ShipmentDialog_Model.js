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

function ShipmentDialog_Model(options){
	var id = 'ShipmentDialog_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = false;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Клиент';
	filed_options.autoInc = false;	
	
	options.fields.clients_ref = new FieldJSON("clients_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объект';
	filed_options.autoInc = false;	
	
	options.fields.destinations_ref = new FieldJSON("destinations_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTime("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.ship_date_time = new FieldDateTime("ship_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество';
	filed_options.autoInc = false;	
	
	options.fields.quant = new FieldFloat("quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Экипаж';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_schedules_ref = new FieldJSON("vehicle_schedules_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Завод';
	filed_options.autoInc = false;	
	
	options.fields.production_sites_ref = new FieldJSON("production_sites_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отгружен';
	filed_options.autoInc = false;	
	
	options.fields.shipped = new FieldBool("shipped",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Оценка';
	filed_options.autoInc = false;	
	
	options.fields.client_mark = new FieldInt("client_mark",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Простой';
	filed_options.autoInc = false;	
	
	options.fields.demurrage = new FieldString("demurrage",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Наличие бланков';
	filed_options.autoInc = false;	
	
	options.fields.blanks_exist = new FieldBool("blanks_exist",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий бухгалетрии';
	filed_options.autoInc = false;	
	
	options.fields.acc_comment = new FieldText("acc_comment",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий (миксер)';
	filed_options.autoInc = false;	
	
	options.fields.acc_comment_shipment = new FieldText("acc_comment_shipment",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_owner_id = new FieldInt("vehicle_owner_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость насос';
	filed_options.autoInc = false;	
	
	options.fields.pump_cost = new FieldFloat("pump_cost",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pump_cost_default = new FieldFloat("pump_cost_default",filed_options);
	options.fields.pump_cost_default.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pump_cost_edit = new FieldBool("pump_cost_edit",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.ship_cost = new FieldFloat("ship_cost",filed_options);
	options.fields.ship_cost.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.ship_cost_default = new FieldFloat("ship_cost_default",filed_options);
	options.fields.ship_cost_default.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.ship_cost_edit = new FieldBool("ship_cost_edit",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Насос';
	filed_options.autoInc = false;	
	
	options.fields.pump_vehicles_ref = new FieldJSON("pump_vehicles_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.order_last_shipment = new FieldBool("order_last_shipment",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pump_for_client_cost = new FieldFloat("pump_for_client_cost",filed_options);
	options.fields.pump_for_client_cost.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pump_for_client_cost_default = new FieldFloat("pump_for_client_cost_default",filed_options);
	options.fields.pump_for_client_cost_default.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pump_for_client_cost_edit = new FieldBool("pump_for_client_cost_edit",filed_options);
	
			
			
		ShipmentDialog_Model.superclass.constructor.call(this,id,options);
}
extend(ShipmentDialog_Model,ModelXML);

