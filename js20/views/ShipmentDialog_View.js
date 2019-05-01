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
function ShipmentDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Shipment_Controller();
	options.model = options.models.ShipmentDialog_Model;
	
	options.addElement = function(){
		this.addElement(new EditInt(id+":id",{
			"inline":true,
			"enabled":false
		}));	
		this.addElement(new EditDateTime(id+":date_time",{
			"inline":true,
			"dateFormat":"d/m/y H:i",
			"editMask":"99/99/99 99:99",
			"enabled":false
		}));	
	
		this.addElement(new ProductionSiteEdit(id+":production_site",{
			"enabled":false
		}));	

		this.addElement(new ClientEdit(id+":client",{
			"enabled":false
		}));	
			
		this.addElement(new DestinationEdit(id+":destination",{
			"enabled":false
		}));	

		this.addElement(new VehicleScheduleEdit(id+":vehicle_schedule",{
			"enabled":false
		}));	

		this.addElement(new ProductionSiteEdit(id+":production_site",{
			"enabled":false
		}));	

		this.addElement(new EditFloat(id+":quant",{
			"labelCaption":"Количество:",
			"editContClassName":("input-group "+window.getBsCol(3)),
			"enabled":false
		}));	

		this.addElement(new EditInt(id+":client_mark",{
			"editContClassName":("input-group "+window.getBsCol(3)),
			"labelCaption":"Баллы:"
		}));	

		this.addElement(new EditCheckBox(id+":blanks_exist",{
			"labelClassName":("control-label "+window.getBsCol(4)),
			"labelCaption":"Бланки:"
		}));	

		this.addElement(new EditTime(id+":demurrage",{
			"editContClassName":("input-group "+window.getBsCol(3)),
			"labelCaption":"Простой:"
		}));	

	}
	
	ShipmentDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("production_site"),"fieldId":"production_sites_ref"})
		,new DataBinding({"control":this.getElement("client"),"fieldId":"clients_ref"})
		,new DataBinding({"control":this.getElement("destination"),"fieldId":"destinations_ref"})
		,new DataBinding({"control":this.getElement("vehicle_schedule"),"fieldId":"vehicle_schedules_ref"})
		,new DataBinding({"control":this.getElement("quant")})
		,new DataBinding({"control":this.getElement("client_mark")})
		,new DataBinding({"control":this.getElement("blanks_exist")})
		,new DataBinding({"control":this.getElement("demurrage")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("client_mark")})
		,new CommandBinding({"control":this.getElement("blanks_exist")})
		,new CommandBinding({"control":this.getElement("demurrage")})
	]);
	
}
extend(ShipmentDialog_View,ViewObjectAjx);
