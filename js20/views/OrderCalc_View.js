/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends View
 * @requires core/extend.js
 * @requires controls/View.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {object} options.calc 
 */
function OrderCalc_View(id,options){
	options = options || {};	
	
	options.template = options.calc? window.getApp().getTemplate("OrderCalc") : null;
	
	this.m_getAvailSpots = options.getAvailSpots;
	this.m_getPayCash = options.getPayCash;
	
	var self = this;
	
	options.addElement = function(){
		var obj_bs_cl = ("control-label "+window.getBsCol(2));
		
		this.addElement(new DestinationEdit(id+":destination",{
			"labelClassName":obj_bs_cl,
			"required":true,
			"acMinLengthForQuery":0,
			"onSelect":function(f){
				self.onSelectDestination(f);
			},
			"onClear":function(){
				self.getElement("destination").getErrorControl().setValue("","info");
			}
		}));	
	
		this.addElement(new EditMoney(id+":quant",{
			"precision":1,
			"labelCaption":"Количество:",
			"labelClassName":obj_bs_cl,
			"editContClassName":("input-group "+window.getBsCol(2)),
			"events":{
				"onchange":function(){
					self.recalcUnloadCost();
					self.recalcTotal();
					if(self.m_getAvailSpots)self.m_getAvailSpots();
				},
				"onkeyup":function(e){
					self.recalcUnloadCost();
					self.recalcTotal();
					if(self.m_getAvailSpots)self.m_getAvailSpots();
				}
			}			
		}));

		this.addElement(new ConcreteTypeEdit(id+":concrete_type",{			
			"labelClassName":obj_bs_cl,
			//"editContClassName":("input-group "+window.getBsCol(7)),
			"onSelect":function(f){
				self.onSelectConcrete(f);
			},
			"required":true
		}));	

		this.addElement(new Enum_unload_types(id+":unload_type",{
			"labelCaption":"Вид насоса:",
			"labelClassName":obj_bs_cl,
			//"editContClassName":("input-group "+window.getBsCol(2)),			
			"defaultValue":"none",
			"addNotSelected":false,
			"events":{
				"change":function(){
					self.changeUnloadType();
					self.recalcTotal();
				}
			}
		}));	

		this.addElement(new PumpVehicleEdit(id+":pump_vehicle",{
			//"enabled":false,
			"labelClassName":obj_bs_cl,
			//"editContClassName":("input-group "+window.getBsCol(7)),
			"onSelect":function(f){
				self.onSelectPumpVehicle(f);
			}
			
		}));	

		this.addElement(new EditMoney(id+":concrete_cost",{
			"labelClassName":("control-label "+window.getBsCol(5))+" orderMoneyFieldLab",
			//"editContClassName":("input-group "+window.getBsCol(7)),
			"className":"form-control orderMoneyField",
			"labelCaption":"Бетон:",
			"enabled":false,
			"value":0,
			"events":{
				"change":function(){
					self.recalcTotal();
				}
			}			
		}));
		
		this.addElement(new EditMoney(id+":destination_cost",{
			"labelClassName":("control-label "+window.getBsCol(5))+" orderMoneyFieldLab",
			//"editContClassName":("input-group"+window.getBsCol(5)),
			"className":"form-control orderMoneyField",
			"labelCaption":"Доставка:",
			"value":0,
			"enabled":false,
			"events":{
				"change":function(){
					self.recalcTotal();
				}
			}			
		}));
		this.addElement(new EditMoney(id+":unload_cost",{
			"labelClassName":("control-label "+window.getBsCol(5))+" orderMoneyFieldLab",
			//"editContClassName":("input-group"+window.getBsCol(7)),
			"className":"form-control orderMoneyField",
			"labelCaption":"Насос:",
			"value":0,
			"enabled":false,
			"events":{
				"change":function(){
					self.recalcTotal();
				}
			}			
		}));
		this.addElement(new EditMoneyEditable(id+":total",{
			"labelClassName":("control-label "+window.getBsCol(5))+" orderMoneyFieldLab",
			//"editContClassName":("input-group"+window.getBsCol(7)),
			"className":"form-control orderMoneyField",
			"labelCaption":"Всего:",
			"value":0,
			"enabled":false
		}));
	
	
	}
		
	OrderCalc_View.superclass.constructor.call(this,id,options);
}

extend(OrderCalc_View,View);

/* Constants */


/* private members */
OrderCalc_View.prototype.m_shipQuantForCostGrade_Model;

/* protected*/


/* public methods */

OrderCalc_View.prototype.onSelectDestination = function(f){
	if(f){
		this.setDestinationPrice(f.price.getValue(),f.distance.getValue(),f.time_route.getValue());
		this.recalcTotal();
	}
}

OrderCalc_View.prototype.setDestinationPrice = function(price,distance,timeRout){
	this.m_destinationPrice = parseFloat(price);
	this.m_destinationDistance = parseFloat(distance);
	
	var dest_inf = "";
	if (!this.getElement("destination").isNull()){
		dest_inf = "Расстояние.:"+distance+" км."+
			",время:"+DateHelper.format(timeRout,"H:i")+
			",цена:"+(this.m_destinationPrice.toFixed(2))+"руб.";
	}	
	this.getElement("destination").getErrorControl().setValue(dest_inf,"info");	
}

OrderCalc_View.prototype.setConcretePrice = function(price){
	this.m_concretePrice = parseFloat(price);
	var inf = this.m_concretePrice? ("Стоимость: "+(this.m_concretePrice).toFixed(2)+" руб/м3"):"";
	this.getElement("concrete_type").getErrorControl().setValue(inf,"info");	
}

OrderCalc_View.prototype.onSelectConcrete = function(f){
	this.setConcretePrice(f.price.getValue());
	this.recalcTotal();
}

OrderCalc_View.prototype.recalcTotalCont = function(){		
	var quant = this.getElement("quant").getValue();
	
	//min quant for destination
	var quant_for_ship_cost = quant;
	this.m_shipQuantForCostGrade_Model.reset();
	while(this.m_shipQuantForCostGrade_Model.getNextRow()){
		var q_to = this.m_shipQuantForCostGrade_Model.getFieldValue("quant_to");
		var q_from = this.m_shipQuantForCostGrade_Model.getFieldValue("quant");
		var dist_to = this.m_shipQuantForCostGrade_Model.getFieldValue("distance_to");
		var dist_from = this.m_shipQuantForCostGrade_Model.getFieldValue("distance_from");
		if(
		this.m_destinationDistance<=dist_to
		&&this.m_destinationDistance>=dist_from
		&& quant<=q_to && quant>=q_from){
			quant_for_ship_cost = q_to;
			break;
		}
	}
	
	var concrete_cost = this.m_concretePrice * quant;
	var destination_cost = this.m_destinationPrice * quant_for_ship_cost;

	this.getElement("destination_cost").setValue(destination_cost);
	this.getElement("concrete_cost").setValue(concrete_cost);

	if(!this.getElement("total").getEnabled()){
		this.getElement("total").setValue(
			(concrete_cost + destination_cost +this.getElement("unload_cost").getValue())
		);
	}
}

OrderCalc_View.prototype.recalcTotal = function(){		
	if (this.m_getPayCash() && !this.getElement("total").getEnabled()){
		//Одна схема для всех доставок!
		if(!this.m_shipQuantForCostGrade_Model){
			var self = this;
			var pm = (new ShipQuantForCostGrade_Controller()).getPublicMethod("get_list");
			pm.run({
				"ok":function(resp){
					self.m_shipQuantForCostGrade_Model = resp.getModel("ShipQuantForCostGrade_Model");
					self.recalcTotalCont();
				}
			})
		}
		else{
			this.recalcTotalCont();	
		}
	}
}


OrderCalc_View.prototype.changeUnloadType = function(){
	var v = this.getElement("unload_type").getValue();
	var ctrl = this.getElement("pump_vehicle");
	var ctrl_pr = this.getElement("unload_cost");
	if(v=="band"||v=="pump"){
		en = true;
	}
	else{
		en = false;
		ctrl.reset();
		ctrl_pr.reset();
	}
	ctrl.setEnabled(en);
	//ctrl_pr.setEnabled(en);
}

OrderCalc_View.prototype.recalcUnloadCost = function(){
	if(this.m_getPayCash()){
		var cost_ctrl = this.getElement("unload_cost");
		var cost = 0;
		if(!this.getElement("pump_vehicle").isNull()
		&&this.m_pumpPriceValue_Model
		&&this.m_pumpPriceValue_Model.getRowCount()
		){			
			var quant = this.getElement("quant").getValue();
			this.m_pumpPriceValue_Model.reset();
			while(this.m_pumpPriceValue_Model.getNextRow()){
				if(quant>=this.m_pumpPriceValue_Model.getFieldValue("quant_from")&&
				quant<=this.m_pumpPriceValue_Model.getFieldValue("quant_to")
				){
					cost = this.m_pumpPriceValue_Model.getFieldValue("price_fixed");
					cost = cost? cost : (this.m_pumpPriceValue_Model.getFieldValue("price_m")*quant);					
					break;
				}
			}
		}
		cost_ctrl.setValue(cost);
	}
}

OrderCalc_View.prototype.onSelectPumpVehicleCont = function(f){
	this.recalcUnloadCost();
	this.recalcTotal();
}

OrderCalc_View.prototype.onSelectPumpVehicle = function(f){
	//read all pump schema
	if(this.getElement("pump_vehicle").isNull()){
		this.onSelectPumpVehicleCont();
	}
	else{	
		if (f.pump_prices_ref.isNull()){
			throw new Error("Не задана ценовая схема для насоса!")
		}
		var contr = new PumpPriceValue_Controller();
		var pm = contr.getPublicMethod("get_list");
		pm.setFieldValue(contr.PARAM_COND_FIELDS,"pump_price_id");
		pm.setFieldValue(contr.PARAM_COND_VALS,f.pump_prices_ref.getValue().getKey());
		pm.setFieldValue(contr.PARAM_COND_SGNS,contr.PARAM_SGN_EQUAL);
		var self = this;
		pm.run({
			"ok":function(resp){
				self.m_pumpPriceValue_Model = resp.getModel("PumpPriceValue_Model");
				self.onSelectPumpVehicleCont();
			}
		});
	}
}

OrderCalc_View.prototype.setPayCash = function(){
	var field_set = document.getElementById(this.getId()+":sum_totals");
	if(this.m_getPayCash()){
		DOMHelper.delClass(field_set,"hidden");
		this.recalcUnloadCost();
		this.recalcTotal();
	}
	else{
		DOMHelper.addClass(field_set,"hidden");
		this.getElement("total").reset();
		this.getElement("destination_cost").reset();
		this.getElement("concrete_cost").reset();
		this.getElement("unload_cost").reset();
	}
}

