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

function Client_Model(options){
	var id = 'Client_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Наименование';
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setRequired(true);
	options.fields.name.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Полное наименование';
	filed_options.autoInc = false;	
	
	options.fields.name_full = new FieldText("name_full",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Сотовый телефон';
	filed_options.autoInc = false;	
	
	options.fields.phone_cel = new FieldString("phone_cel",filed_options);
	options.fields.phone_cel.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.manager_comment = new FieldText("manager_comment",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид контрагента';
	filed_options.autoInc = false;	
	
	options.fields.client_type_id = new FieldInt("client_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Тип контрагента';
	filed_options.autoInc = false;	
	
	options.fields.client_kind = new FieldEnum("client_kind",filed_options);
	filed_options.enumValues = 'buyer,acc,else';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Источник обращения';
	filed_options.autoInc = false;	
	
	options.fields.client_come_from_id = new FieldInt("client_come_from_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Менеджер';
	filed_options.autoInc = false;	
	
	options.fields.manager_id = new FieldInt("manager_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.create_date = new FieldDate("create_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.email = new FieldString("email",filed_options);
	options.fields.email.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.inn = new FieldString("inn",filed_options);
	options.fields.inn.getValidator().setMaxLength('12');
	
			
			
		Client_Model.superclass.constructor.call(this,id,options);
}
extend(Client_Model,ModelXML);

