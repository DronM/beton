/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SupplierDialog_View(id,options){	

	options = options || {};
	options.controller = new Supplier_Controller();
	options.model = options.models.Supplier_Model;
	
	SupplierDialog_View.superclass.constructor.call(this,id,options);
	
	this.addElement(new EditString(id+":name",{
		"labelCaption":"Наименование:",
		"required":true,
		"maxLength":100
	}));	
	
	this.addElement(new ClientNameFullEdit(id+":name_full",{
	}));	
	
	this.addElement(new EditPhone(id+":tel",{
		"labelCaption":"Телефон:",
	}));	

	this.addElement(new EditPhone(id+":tel2",{
		"labelCaption":"Телефон:",
	}));	
	
	
	this.addElement(new LangEditRef(id+":lang"));	
	
	
	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("name_full")})
		,new DataBinding({"control":this.getElement("lang"),"fieldId":"lang_id"})
		,new DataBinding({"control":this.getElement("tel")})
		,new DataBinding({"control":this.getElement("tel2")})
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")})
		,new CommandBinding({"control":this.getElement("name_full")})
		,new CommandBinding({"control":this.getElement("lang"),"fieldId":"lang_id"})
		,new CommandBinding({"control":this.getElement("tel")})
		,new CommandBinding({"control":this.getElement("tel2")})
	]);
	
}
extend(SupplierDialog_View,ViewObjectAjx);
