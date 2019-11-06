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

function Vehicle_Model(options){
	var id = 'Vehicle_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	options.fields.id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер';
	filed_options.autoInc = false;	
	
	options.fields.plate = new FieldString("plate",filed_options);
	options.fields.plate.getValidator().setRequired(true);
	options.fields.plate.getValidator().setMaxLength('6');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Грузоподъемность';
	filed_options.autoInc = false;	
	
	options.fields.load_capacity = new FieldFloat("load_capacity",filed_options);
	options.fields.load_capacity.getValidator().setRequired(true);
	options.fields.load_capacity.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Марка';
	filed_options.autoInc = false;	
	
	options.fields.make = new FieldString("make",filed_options);
	options.fields.make.getValidator().setMaxLength('20');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.driver_id = new FieldInt("driver_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Свойство';
	filed_options.autoInc = false;	
	
	options.fields.feature = new FieldString("feature",filed_options);
	options.fields.feature.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Трэкер';
	filed_options.autoInc = false;	
	
	options.fields.tracker_id = new FieldString("tracker_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Идентификатор SIM карты';
	filed_options.autoInc = false;	
	
	options.fields.sim_id = new FieldString("sim_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер телефона SIM карты';
	filed_options.autoInc = false;	
	
	options.fields.sim_number = new FieldString("sim_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Владелец';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_owner_id = new FieldInt("vehicle_owner_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_owners = new FieldJSONB("vehicle_owners",filed_options);
	
			
			
			
			
		Vehicle_Model.superclass.constructor.call(this,id,options);
}
extend(Vehicle_Model,ModelXML);

