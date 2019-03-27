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

function LabData_Model(options){
	var id = 'LabData_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Отгрузка';
	filed_options.autoInc = false;	
	
	options.fields.shipment_id = new FieldInt("shipment_id",filed_options);
	options.fields.shipment_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'ОК см';
	filed_options.autoInc = false;	
	
	options.fields.ok_sm = new FieldFloat("ok_sm",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'масса';
	filed_options.autoInc = false;	
	
	options.fields.weight = new FieldFloat("weight",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'масса норм';
	filed_options.autoInc = false;	
	
	options.fields.weight_norm = new FieldFloat("weight_norm",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '%';
	filed_options.autoInc = false;	
	
	options.fields.percent_1 = new FieldFloat("percent_1",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p1';
	filed_options.autoInc = false;	
	
	options.fields.p_1 = new FieldFloat("p_1",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p2';
	filed_options.autoInc = false;	
	
	options.fields.p_2 = new FieldFloat("p_2",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p3';
	filed_options.autoInc = false;	
	
	options.fields.p_3 = new FieldFloat("p_3",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p4';
	filed_options.autoInc = false;	
	
	options.fields.p_4 = new FieldFloat("p_4",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p7';
	filed_options.autoInc = false;	
	
	options.fields.p_7 = new FieldFloat("p_7",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p28';
	filed_options.autoInc = false;	
	
	options.fields.p_28 = new FieldFloat("p_28",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'p_norm';
	filed_options.autoInc = false;	
	
	options.fields.p_norm = new FieldFloat("p_norm",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'percent_2';
	filed_options.autoInc = false;	
	
	options.fields.percent_2 = new FieldFloat("percent_2",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.lab_comment = new FieldText("lab_comment",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№';
	filed_options.autoInc = false;	
	
	options.fields.num = new FieldText("num",filed_options);
	
		LabData_Model.superclass.constructor.call(this,id,options);
}
extend(LabData_Model,ModelXML);

