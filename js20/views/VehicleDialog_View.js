/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleDialog_View(id,options){	

	options = options || {};
	options.controller = new Vehicle_Controller();
	options.model = options.models.VehicleDialog_Model;
	
	VehicleDialog_View.superclass.constructor.call(this,id,options);
	
	this.addElement(new EditString(id+":plate",{
		"labelCaption":"Рег.номер:",
		"maxLength":"6",
		"required":true
	}));	
	this.addElement(new EditFloat(id+":load_capacity",{
		"precision":"2",
		"labelCaption":"Грузоподъемность:"
	}));	
	this.addElement(new DriverEditRef(id+":driver"));	
	
	this.addElement(new MakeEdit(id+":make"));	
	
	this.addElement(new FeatureEdit(id+":feature"));	
	
	this.addElement(new GPSTrackerRef(id+":tracker_id"));	
	
	this.addElement(new EditString(id+":sim_id",{
		"maxLength":"20",
		"labelCaption":"Идентификатор СИМ карты:",
		"enabled":false
	}));	

	this.addElement(new EditPhone(id+":sim_number",{
		"labelCaption":"Номер телефона СИМ карты:",
		"enabled":false
	}));	

	this.addElement(new EditDateTime(id+":tracker_last_dt",{
		"labelCaption":"Последние данные трэкера:",
		"enabled":false
	}));	

	this.addElement(new OwnerListGrid(id+":owners",{
	}));	

	
	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("plate")})
		,new DataBinding({"control":this.getElement("load_capacity")})
		,new DataBinding({"control":this.getElement("driver")})
		,new DataBinding({"control":this.getElement("make")})
		,new DataBinding({"control":this.getElement("owners"),"fieldId":"vehicle_owners"})
		,new DataBinding({"control":this.getElement("feature")})
		,new DataBinding({"control":this.getElement("tracker_id")})
		,new DataBinding({"control":this.getElement("sim_id")})
		,new DataBinding({"control":this.getElement("sim_number")})
		,new DataBinding({"control":this.getElement("tracker_last_dt")})
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("plate")})
		,new CommandBinding({"control":this.getElement("load_capacity")})
		,new CommandBinding({"control":this.getElement("driver"),"fieldId":"driver_id"})
		,new CommandBinding({"control":this.getElement("make")})
		,new CommandBinding({"control":this.getElement("owners"),"fieldId":"vehicle_owners"})
		,new CommandBinding({"control":this.getElement("feature")})
		,new CommandBinding({"control":this.getElement("tracker_id")})
		//,new CommandBinding({"control":this.getElement("sim_id")})
		//,new CommandBinding({"control":this.getElement("sim_number")})
	]);
	
}
extend(VehicleDialog_View,ViewObjectAjx);

VehicleDialog_View.prototype.onGetData = function(resp,cmd){
	VehicleDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	if(window.getApp().getServVar("role_id")=="vehicle_owner"){
		this.setEnabled(false);
		this.getControlOK().setEnabled(true);
		this.getControlSave().setEnabled(true);
		this.getControlCancel().setEnabled(true);
	}
}
