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

function VehicleRouteCashe_Model(options){
	var id = 'VehicleRouteCashe_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Трэкер';
	filed_options.autoInc = false;	
	
	options.fields.tracker_id = new FieldString("tracker_id",filed_options);
	options.fields.tracker_id.getValidator().setRequired(true);
	options.fields.tracker_id.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.shipment_id = new FieldInt("shipment_id",filed_options);
	options.fields.shipment_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Состояние ТС';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_state = new FieldEnum("vehicle_state",filed_options);
	filed_options.enumValues = 'shift,free,assigned,busy,left_for_dest,at_dest,left_for_base,out_from_shift,out,shift_added';
	options.fields.vehicle_state.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Время последнего обновления';
	filed_options.autoInc = false;	
	
	options.fields.update_dt = new FieldDateTimeTZ("update_dt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Данные маршрута OSRM';
	filed_options.autoInc = false;	
	
	options.fields.route = new FieldJSONB("route",filed_options);
	options.fields.route.getValidator().setRequired(true);
	
		VehicleRouteCashe_Model.superclass.constructor.call(this,id,options);
}
extend(VehicleRouteCashe_Model,ModelXML);

