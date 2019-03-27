/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleScheduleDialog_View(id,options){	

	options = options || {};
	options.controller = new VehicleSchedule_Controller();
	options.model = options.models.VehicleScheduleList_Model;
	//var dt = (options.filters&&options.filters.VehicleScheduleList_Model)? options.filters.VehicleScheduleList_Model.schedule_date:DateHelper.time();
	var dt = (options.schedule_date)? options.schedule_date:DateHelper.time();
	
	VehicleScheduleDialog_View.superclass.constructor.call(this,id,options);

	this.addElement(new EditDate(id+":schedule_date",{
		"labelCaption":"Дата:",
		"value":dt,
		"required":true
	}));	
	
	this.addElement(new VehicleEdit(id+":vehicle",{
		"required":true
	}));	
	this.addElement(new DriverEditRef(id+":driver",{
		"required":true
	}));	
	
	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("vehicle"),"fieldId":"vehicles_ref"})
		,new DataBinding({"control":this.getElement("driver"),"fieldId":"drivers_ref"})
		,new DataBinding({"control":this.getElement("schedule_date")})
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("vehicle"),"fieldId":"vehicle_id"})
		,new CommandBinding({"control":this.getElement("driver"),"fieldId":"driver_id"})
		,new CommandBinding({"control":this.getElement("schedule_date")})
	]);
	
}
extend(VehicleScheduleDialog_View,ViewObjectAjx);
