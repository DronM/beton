/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function SMSPatternDialog_View(id,options){	

	options = options || {};
	
	options.controller = new SMSPattern_Controller();
	options.model = options.models.SMSPatternList_Model;
	
	if (options.model&&options.model.getRowIndex())
		options.model.getNextRow();
	
	options.addElement = function(){
		this.addElement(new Enum_sms_types(id+":sms_type",{
			"labelCaption":"Тип:",
			"required":true
		}));	

		this.addElement(new LangEditRef(id+":langs_ref",{
			"required":true
		}));	
			
		this.addElement(new EditText(id+":pattern",{
			"labelCaption":"Текст шаблона:",
			"required":true
		}));	

		this.addElement(new SMSPatternUserPhoneList_View(id+":user_phones",{
			"detail":true
		}));	
	}
	
	SMSPatternDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("sms_type")})
		,new DataBinding({"control":this.getElement("langs_ref")})
		,new DataBinding({"control":this.getElement("pattern")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("sms_type")})
		,new CommandBinding({"control":this.getElement("langs_ref"),"fieldId":"lang_id"})
		,new CommandBinding({"control":this.getElement("pattern")})
	]);
	
	this.addDetailDataSet({
		"control":this.getElement("user_phones").getElement("grid"),
		"controlFieldId":"sms_pattern_id",
		"value":options.model.getFieldValue("id")
	});
		
}
extend(SMSPatternDialog_View,ViewObjectAjx);
