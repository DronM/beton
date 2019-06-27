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
	
	var self = this;
	
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

		this.addElement(new EditInterval(id+":demurrage",{
			"editContClassName":("input-group "+window.getBsCol(3)),
			"labelCaption":"Простой:",
			"editMask":"99:99"
		}));	

		this.addElement(new EditText(id+":acc_comment",{
			"labelCaption":"Комментарий бухгалтерии (насос):"
		}));
		this.addElement(new EditText(id+":acc_comment_shipment",{
			"labelCaption":"Комментарий бухгалтерии (миксер):"
		}));
		
		this.addElement(new EditMoneyEditable(id+":pump_cost",{
			"className":"form-control orderMoneyField",
			"labelCaption":"Стомисоть насос:",
			"value":0,
			"enabled":false
			,"onToggleEditable":function(){
				if(!self.getElement("pump_cost").getEditAllowed()){
					self.getElement("pump_cost").setValue(self.getModel().getFieldValue("pump_cost_default"));
				}
			}
		}));

		this.addElement(new EditMoneyEditable(id+":ship_cost",{
			"className":"form-control orderMoneyField",
			"labelCaption":"Стомисоть доставки:",
			"value":0,
			"enabled":false
			,"onToggleEditable":function(){
				if(!self.getElement("ship_cost").getEditAllowed()){
					self.getElement("ship_cost").setValue(self.getModel().getFieldValue("ship_cost_default"));
				}
			}
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
		,new DataBinding({"control":this.getElement("acc_comment")})
		,new DataBinding({"control":this.getElement("acc_comment_shipment")})
		,new DataBinding({"control":this.getElement("pump_cost")})
		,new DataBinding({"control":this.getElement("ship_cost")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({
			"func":function(pm){
				if(self.getPumpCostEditModified()){
					var pump_cost_edit = !self.m_model.getFieldValue("pump_cost_edit");
					pm.setFieldValue("pump_cost_edit",pump_cost_edit);
					if(pump_cost_edit){
						pm.setFieldValue("pump_cost",this.getElement("pump_cost").getValue());
					}
					else{
						pm.unsetFieldValue("pump_cost");
					}
				}
				else{
					pm.unsetFieldValue("pump_cost_edit");
				}
				
				if(self.getShipCostEditModified()){
					var ship_cost_edit = !self.m_model.getFieldValue("ship_cost_edit");
					pm.setFieldValue("ship_cost_edit",ship_cost_edit);
					if(ship_cost_edit){
						pm.setFieldValue("ship_cost",this.getElement("ship_cost").getValue());
					}
					else{
						pm.unsetFieldValue("ship_cost");
					}
				}
				else{
					pm.unsetFieldValue("ship_cost_edit");
				}
				
			}
		})
	
		,new CommandBinding({"control":this.getElement("client_mark")})
		,new CommandBinding({"control":this.getElement("blanks_exist")})
		,new CommandBinding({"control":this.getElement("demurrage")})
		,new CommandBinding({"control":this.getElement("acc_comment")})
		,new CommandBinding({"control":this.getElement("acc_comment_shipment")})
		,new CommandBinding({"control":this.getElement("pump_cost")})
		,new CommandBinding({"control":this.getElement("ship_cost")})
	]);
	
}
extend(ShipmentDialog_View,ViewObjectAjx);

ShipmentDialog_View.prototype.getModified = function(cmd){
	return (
		ShipmentDialog_View.superclass.getModified.call(this,cmd)
		|| this.getPumpCostEditModified()
		|| this.getElement("pump_cost").getModified()
		|| this.getShipCostEditModified()
		|| this.getElement("ship_cost").getModified()		
	);
}

ShipmentDialog_View.prototype.getPumpCostEditModified = function(pm){
	return (this.getElement("pump_cost").getVisible() && this.getElement("pump_cost").getEditAllowed()!=this.m_model.getFieldValue("pump_cost_edit"));
}

ShipmentDialog_View.prototype.getShipCostEditModified = function(pm){
	return (this.getElement("ship_cost").getEditAllowed()!=this.m_model.getFieldValue("ship_cost_edit"));
}

ShipmentDialog_View.prototype.onGetData = function(resp,cmd){
	ShipmentDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	var m = this.getModel();

	var pv = m.getFieldValue("pump_vehicles_ref");
	if(!pv || pv.isNull() || !m.getFieldValue("order_last_shipment")){
		this.getElement("pump_cost").setVisible(false);
	}
	else{
		this.getElement("pump_cost").setEditAllowed(m.getFieldValue("pump_cost_edit"));
	}
	
	this.getElement("ship_cost").setVisible(true);
	this.getElement("ship_cost").setEditAllowed(m.getFieldValue("ship_cost_edit"));
	
}
