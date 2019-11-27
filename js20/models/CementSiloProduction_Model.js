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

function CementSiloProduction_Model(options){
	var id = 'CementSiloProduction_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	options.fields.id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cement_silo_id = new FieldInt("cement_silo_id",filed_options);
	options.fields.cement_silo_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTimeTZ("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.production_date_time = new FieldDateTimeTZ("production_date_time",filed_options);
	options.fields.production_date_time.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.production_vehicle_descr = new FieldString("production_vehicle_descr",filed_options);
	options.fields.production_vehicle_descr.getValidator().setRequired(true);
	options.fields.production_vehicle_descr.getValidator().setMaxLength('5');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_id = new FieldInt("vehicle_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.vehicle_state = new FieldEnum("vehicle_state",filed_options);
	filed_options.enumValues = 'shift,free,assigned,busy,left_for_dest,at_dest,left_for_base,out_from_shift,out,shift_added';
	options.fields.vehicle_state.getValidator().setRequired(true);
	
			
		CementSiloProduction_Model.superclass.constructor.call(this,id,options);
}
extend(CementSiloProduction_Model,ModelXML);

