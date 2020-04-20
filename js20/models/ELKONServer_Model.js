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

function ELKONServer_Model(options){
	var id = 'ELKONServer_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Наименование базы данных';
	filed_options.autoInc = false;	
	
	options.fields.data_base_name = new FieldString("data_base_name",filed_options);
	options.fields.data_base_name.getValidator().setRequired(true);
	options.fields.data_base_name.getValidator().setMaxLength('150');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Имя пользователя';
	filed_options.autoInc = false;	
	
	options.fields.user_name = new FieldString("user_name",filed_options);
	options.fields.user_name.getValidator().setRequired(true);
	options.fields.user_name.getValidator().setMaxLength('150');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Пароль пользователя';
	filed_options.autoInc = false;	
	
	options.fields.user_password = new FieldString("user_password",filed_options);
	options.fields.user_password.getValidator().setRequired(true);
	options.fields.user_password.getValidator().setMaxLength('150');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'IP хоста';
	filed_options.autoInc = false;	
	
	options.fields.host = new FieldString("host",filed_options);
	options.fields.host.getValidator().setRequired(true);
	options.fields.host.getValidator().setMaxLength('150');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Порт хоста';
	filed_options.autoInc = false;	
	
	options.fields.port = new FieldInt("port",filed_options);
	options.fields.port.getValidator().setRequired(true);
	
		ELKONServer_Model.superclass.constructor.call(this,id,options);
}
extend(ELKONServer_Model,ModelXML);

