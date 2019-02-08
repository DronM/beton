/* Copyright (c) 2016
 *	Andrey Mikhalevich, Katren ltd.
 */
function UserDialog_View(id,options){	

	options = options || {};
	options.controller = new User_Controller();
	options.model = options.models.UserDialog_Model;
	
	UserDialog_View.superclass.constructor.call(this,id,options);
	
	this.addElement(new UserNameEdit(id+":name"));

	this.addElement(new Enum_role_types(id+":role",{
		"labelCaption":"Роль:",
		"required":true
	}));	
	
	this.addElement(new EditEmail(id+":email",{
		"labelCaption":"Эл.почта:"
	}));	

	this.addElement(new EditPhone(id+":phone_cel",{
		"labelCaption":"Моб.телефон:"
	}));

	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("name")}),
		new DataBinding({"control":this.getElement("role"),"field":this.m_model.getField("role_id")}),
		new DataBinding({"control":this.getElement("email")})
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")}),
		new CommandBinding({"control":this.getElement("role"),"fieldId":"role_id"}),
		new CommandBinding({"control":this.getElement("email")})
	]);
	
	this.addDetailDataSet({
		"control":mac_grid.getElement("mac-grid"),
		"controlFieldId":"user_id",
		"field":this.m_model.getField("id")
	});
	
	this.addDetailDataSet({
		"control":config_grid.getElement("config-grid"),
		"controlFieldId":"user_id",
		"field":this.m_model.getField("id")
	});
	
	var self = this;
	
}
extend(UserDialog_View,ViewObjectAjx);
