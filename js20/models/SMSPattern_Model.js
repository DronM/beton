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

function SMSPattern_Model(options){
	var id = 'SMSPattern_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Язык';
	filed_options.autoInc = false;	
	
	options.fields.lang_id = new FieldInt("lang_id",filed_options);
	options.fields.lang_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Тип SMS';
	filed_options.autoInc = false;	
	
	options.fields.sms_type = new FieldEnum("sms_type",filed_options);
	filed_options.enumValues = 'order,ship,remind,procur,order_for_pump_ins,order_for_pump_upd,order_for_pump_del,remind_for_pump,client_thank';
	options.fields.sms_type.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Шаблон';
	filed_options.autoInc = false;	
	
	options.fields.pattern = new FieldText("pattern",filed_options);
	options.fields.pattern.getValidator().setRequired(true);
	
			
		SMSPattern_Model.superclass.constructor.call(this,id,options);
}
extend(SMSPattern_Model,ModelXML);

