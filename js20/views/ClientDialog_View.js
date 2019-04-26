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
function ClientDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Client_Controller();
	options.model = options.models.ClientDialog_Model;
	
	options.addElement = function(){
		this.addElement(new ClientNameEdit(id+":name",{
			"view":this,
			"required":true,
			"focus":true
		}));	

		this.addElement(new ClientNameFullEdit(id+":name_full",{
			"required":true
		}));	
			
		this.addElement(new EditEmail(id+":email",{
			"labelCaption":"Эл.почта:"
		}));	

		this.addElement(new EditPhone(id+":phone_cel",{
			"labelCaption":"Телефон:"
		}));	

		this.addElement(new EditText(id+":manager_comment",{
			"labelCaption":"Комментарий:"
		}));	

		this.addElement(new Enum_client_kinds(id+":client_kind",{
			"labelCaption":"Тип клиента:"
		}));	

		this.addElement(new UserEditRef(id+":manager",{
			"labelCaption":"Менеджер:"
		}));	

		this.addElement(new ClientTypeEdit(id+":client_type"));	

		this.addElement(new ClientComeFromEdit(id+":client_come_from"));
		
		this.addElement(new ClientTelList_View(id+":client_tel_list",{
			"detail":true
		}));		
						
	}
	
	ClientDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("name_full")})
		,new DataBinding({"control":this.getElement("phone_cel")})
		,new DataBinding({"control":this.getElement("email")})
		,new DataBinding({"control":this.getElement("client_kind")})
		,new DataBinding({"control":this.getElement("manager_comment")})
		,new DataBinding({"control":this.getElement("manager"),"fieldId":"users_ref"})
		,new DataBinding({"control":this.getElement("client_come_from"),"fieldId":"client_come_from"})
		,new DataBinding({"control":this.getElement("client_type"),"fieldId":"client_type"})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")})
		,new CommandBinding({"control":this.getElement("name_full")})
		,new CommandBinding({"control":this.getElement("phone_cel")})
		,new CommandBinding({"control":this.getElement("email")})
		,new CommandBinding({"control":this.getElement("client_kind")})
		,new CommandBinding({"control":this.getElement("manager_comment")})
		,new CommandBinding({"control":this.getElement("manager"),"fieldId":"manager_id"})
		,new CommandBinding({"control":this.getElement("client_come_from"),"fieldId":"client_come_from_id"})
		,new CommandBinding({"control":this.getElement("client_type"),"fieldId":"client_type_id"})
	]);
	
	this.addDetailDataSet({
		"control":this.getElement("client_tel_list").getElement("grid"),
		"controlFieldId":"client_id",
		"fieldId":"id"
	});
		
}
extend(ClientDialog_View,ViewObjectAjx);
