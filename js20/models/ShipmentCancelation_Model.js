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

function ShipmentCancelation_Model(options){
	var id = 'ShipmentCancelation_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Дата';
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTimeTZ("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата отгрузки';
	filed_options.autoInc = false;	
	
	options.fields.ship_date_time = new FieldDateTimeTZ("ship_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата назначения';
	filed_options.autoInc = false;	
	
	options.fields.assign_date_time = new FieldDateTimeTZ("assign_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Заявка';
	filed_options.autoInc = false;	
	
	options.fields.order_id = new FieldInt("order_id",filed_options);
	options.fields.order_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Экипаж';
	filed_options.autoInc = false;	
	
	options.fields.vehicle_schedule_id = new FieldInt("vehicle_schedule_id",filed_options);
	options.fields.vehicle_schedule_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.comment_text = new FieldText("comment_text",filed_options);
	options.fields.comment_text.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Пользователь';
	filed_options.autoInc = false;	
	
	options.fields.user_id = new FieldInt("user_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Количество';
	filed_options.autoInc = false;	
	
	options.fields.quant = new FieldFloat("quant",filed_options);
	options.fields.quant.getValidator().setMaxLength('19');
	
		ShipmentCancelation_Model.superclass.constructor.call(this,id,options);
}
extend(ShipmentCancelation_Model,ModelXML);

