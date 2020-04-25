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

function Production_Model(options){
	var id = 'Production_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	options.fields.id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Elkon production ID';
	filed_options.autoInc = false;	
	
	options.fields.production_id = new FieldInt("production_id",filed_options);
	options.fields.production_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Начало производства в Elkon';
	filed_options.autoInc = false;	
	
	options.fields.production_dt_start = new FieldDateTimeTZ("production_dt_start",filed_options);
	options.fields.production_dt_start.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Окончание производства в Elkon';
	filed_options.autoInc = false;	
	
	options.fields.production_dt_end = new FieldDateTimeTZ("production_dt_end",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Пользователь Elkon';
	filed_options.autoInc = false;	
	
	options.fields.production_user = new FieldString("production_user",filed_options);
	options.fields.production_user.getValidator().setMaxLength('150');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ТС в Elkon';
	filed_options.autoInc = false;	
	
	options.fields.production_vehicle_descr = new FieldString("production_vehicle_descr",filed_options);
	options.fields.production_vehicle_descr.getValidator().setRequired(true);
	options.fields.production_vehicle_descr.getValidator().setMaxLength('5');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.dt_start_set = new FieldDateTimeTZ("dt_start_set",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.dt_end_set = new FieldDateTimeTZ("dt_end_set",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.production_site_id = new FieldInt("production_site_id",filed_options);
	options.fields.production_site_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.shipment_id = new FieldInt("shipment_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.concrete_type_id = new FieldInt("concrete_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_schedule_state_id = new FieldInt("vehicle_schedule_state_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_id = new FieldInt("vehicle_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.production_concrete_type_descr = new FieldText("production_concrete_type_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.material_tolerance_violated = new FieldBool("material_tolerance_violated",filed_options);
	
			
			
			
		Production_Model.superclass.constructor.call(this,id,options);
}
extend(Production_Model,ModelXML);

