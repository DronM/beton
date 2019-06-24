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

function ShipmentForVehOwnerList_Model(options){
	var id = 'ShipmentForVehOwnerList_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
				
				
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Номер';
	filed_options.autoInc = false;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата отгрузки';
	filed_options.autoInc = false;	
	
	options.fields.ship_date_time = new FieldDateTime("ship_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объект';
	filed_options.autoInc = false;	
	
	options.fields.destinations_ref = new FieldJSON("destinations_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.destination_id = new FieldInt("destination_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Марка';
	filed_options.autoInc = false;	
	
	options.fields.concrete_types_ref = new FieldJSON("concrete_types_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.concrete_type_id = new FieldInt("concrete_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество';
	filed_options.autoInc = false;	
	
	options.fields.quant = new FieldFloat("quant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Автомобиль';
	filed_options.autoInc = false;	
	
	options.fields.vehicles_ref = new FieldJSON("vehicles_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_id = new FieldInt("vehicle_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Водитель';
	filed_options.autoInc = false;	
	
	options.fields.drivers_ref = new FieldJSON("drivers_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.driver_id = new FieldInt("driver_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_owner_id = new FieldInt("vehicle_owner_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Владелец';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_owners_ref = new FieldJSON("vehicle_owners_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость доставки';
	filed_options.autoInc = false;	
	
	options.fields.cost = new FieldFloat("cost",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость доставки для водителя';
	filed_options.autoInc = false;	
	
	options.fields.cost_for_driver = new FieldFloat("cost_for_driver",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость доставки отредактирована';
	filed_options.autoInc = false;	
	
	options.fields.ship_cost_edit = new FieldBool("ship_cost_edit",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Простой';
	filed_options.autoInc = false;	
	
	options.fields.demurrage = new FieldString("demurrage",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стомость простоя';
	filed_options.autoInc = false;	
	
	options.fields.demurrage_cost = new FieldFloat("demurrage_cost",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий бухгалетрии';
	filed_options.autoInc = false;	
	
	options.fields.acc_comment = new FieldText("acc_comment",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Согласовано миксер';
	filed_options.autoInc = false;	
	
	options.fields.owner_agreed = new FieldBool("owner_agreed",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата согласования миксер';
	filed_options.autoInc = false;	
	
	options.fields.owner_agreed_date_time = new FieldDateTimeTZ("owner_agreed_date_time",filed_options);
	
			
			
		ShipmentForVehOwnerList_Model.superclass.constructor.call(this,id,options);
}
extend(ShipmentForVehOwnerList_Model,ModelXML);

