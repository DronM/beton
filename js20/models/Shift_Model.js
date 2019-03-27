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

function Shift_Model(options){
	var id = 'Shift_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Дата';
	filed_options.autoInc = false;	
	
	options.fields.date = new FieldDateTime("date",filed_options);
	options.fields.date.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Закрыта';
	filed_options.autoInc = false;	
	
	options.fields.closed = new FieldBool("closed",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата закрытия';
	filed_options.autoInc = false;	
	
	options.fields.close_date_time = new FieldDateTime("close_date_time",filed_options);
	
		Shift_Model.superclass.constructor.call(this,id,options);
}
extend(Shift_Model,ModelXML);

