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

function LabEntry30DaysList_Model(options){
	var id = 'LabEntry30DaysList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.concrete_type_id = new FieldInt("concrete_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Марка';
	filed_options.autoInc = false;	
	
	options.fields.concrete_type_descr = new FieldString("concrete_type_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Всего машин';
	filed_options.autoInc = false;	
	
	options.fields.cnt = new FieldInt("cnt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Всего по будням';
	filed_options.autoInc = false;	
	
	options.fields.day_cnt = new FieldInt("day_cnt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отбор по будням';
	filed_options.autoInc = false;	
	
	options.fields.selected_cnt = new FieldInt("selected_cnt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отбор по будням';
	filed_options.autoInc = false;	
	
	options.fields.selected_avg_cnt = new FieldJSON("selected_avg_cnt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Надо еще';
	filed_options.autoInc = false;	
	
	options.fields.need_cnt = new FieldInt("need_cnt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ОК';
	filed_options.autoInc = false;	
	
	options.fields.ok = new FieldInt("ok",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'П7%';
	filed_options.autoInc = false;	
	
	options.fields.p7 = new FieldInt("p7",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'П28%';
	filed_options.autoInc = false;	
	
	options.fields.p28 = new FieldInt("p28",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отбор';
	filed_options.autoInc = false;	
	
	options.fields.selected_cnt2 = new FieldInt("selected_cnt2",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ОК';
	filed_options.autoInc = false;	
	
	options.fields.ok2 = new FieldInt("ok2",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'П7%';
	filed_options.autoInc = false;	
	
	options.fields.p72 = new FieldInt("p72",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'П28%';
	filed_options.autoInc = false;	
	
	options.fields.p282 = new FieldInt("p282",filed_options);
	
			
		LabEntry30DaysList_Model.superclass.constructor.call(this,id,options);
}
extend(LabEntry30DaysList_Model,ModelXML);

