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
	
		this.addElement(new EditInt(id+":quant",{
			"labelCaption":"Количество:",
			"labelClassName":obj_bs_cl,
			//"editContClassName":("input-group "+window.getBsCol(7)),
			"events":{
				"onchange":function(){
					self.recalcTotal();						
					if(self.m_getAvailSpots)self.m_getAvailSpots();
				},
				"onkeyup":function(e){
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
			//"editContClassName":("input-group "+window.getBsCol(7)),			
			"defaultValue":"none",
			"addNotSelected":false,
			"events":{
				"change":function(){
					self.changeUnloadType();
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
		
		this.addElement(new EditMoney(id+":destination_price",{
			"labelClassName":("control-label "+window.getBsCol(5))+" orderMoneyFieldLab",
			"editContClassName":("input-group "+window.getBsCol(7)),
			"className":"form-control orderMoneyField",
			"labelCaption":"Доставка:",
			"value":0,
			"events":{
				"change":function(){
					self.recalcTotal();
				}
			}			
		}));
		this.addElement(new EditMoney(id+":unload_price",{
			"labelClassName":("control-label "+window.getBsCol(4))+" orderMoneyFieldLab",
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
			"labelClassName":("control-label "+window.getBsCol(4))+" orderMoneyFieldLab",
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
	if(f)
		this.onSelectDestinationCont(f.price.getValue(),f.distance.getValue(),f.time_route.getValue());
}

OrderCalc_View.prototype.onSelectDestinationCont = function(price,distance,timeRout){
	this.m_destinationPrice = parseFloat(price);
	
	var dest_inf = "";
	if (!this.getElement("destination").isNull()){
		dest_inf = "Расстояние.:"+distance+" км."+
			",время:"+DateHelper.format(timeRout,"H:i")+
			",цена:"+(this.m_destinationPrice.toFixed(2))+"руб.";
	}	
	this.getElement("destination").getErrorControl().setValue(dest_inf,"info");
	
	if(this.m_getPayCash()){
		this.getElement("destination_price").setValue(this.m_destinationPrice);
		this.recalcTotal();
	}	
}

OrderCalc_View.prototype.onSelectConcrete = function(f){
	this.m_concretePrice = parseFloat(f.price.getValue());
	var inf = this.m_concretePrice? ("Стоимость: "+(this.m_concretePrice).toFixed(2)+" руб/м3"):"";
	this.getElement("concrete_type").getErrorControl().setValue(inf,"info");
	
	this.recalcTotal();
}

OrderCalc_View.prototype.recalcTotalCont = function(){		
//console.log("OrderDialog_View.prototype.recalcTotal ")
	if (!this.getElement("total").getEnabled()){
		var quant = this.getElement("quant").getValue();
		//min check
		var quant_for_ship_cost = quant;
		this.m_shipQuantForCostGrade_Model.reset();
		while(this.m_shipQuantForCostGrade_Model.getNextRow()){
			var q = this.m_shipQuantForCostGrade_Model.getFieldValue("quant");
			if(quant<=q){
				quant_for_ship_cost = q;
				break;
			}
		}
		
/*console.log("this.m_concretePrice="+this.m_concretePrice)
console.log("quant="+quant)
console.log("QuantForDestination="+( (quant<dest_min_q)? dest_min_q:quant))								
console.log("destination_price="+this.getElement("destination_price").getValue())
console.log("dest_min_q="+dest_min_q)*/

		this.getElement("total").setValue(
			(this.m_concretePrice * quant +
			quant_for_ship_cost * this.getElement("destination_price").getValue() +
			this.getElement("unload_price").getValue()
			)
		);
	}
}

OrderCalc_View.prototype.recalcTotal = function(){		
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


OrderCalc_View.prototype.changeUnloadType = function(){
	var v = this.getElement("unload_type").getValue();
	var ctrl = this.getElement("pump_vehicle");
	var ctrl_pr = this.getElement("unload_price");
	if(v=="band"||v=="pump"){
		en = true;
	}
	else{
		en = false;
		ctrl.reset();
		ctrl_pr.reset();
	}
	ctrl.setEnabled(en);
	ctrl_pr.setEnabled(en);
}

OrderCalc_View.prototype.recalcUnloadCost = function(){
//console.log("OrderDialog_View.prototype.recalcUnloadCost")
	if(this.m_getPayCash()){
		if(!this.getElement("pump_vehicle").isNull()
		&&this.m_pumpPriceValue_Model
		&&this.m_pumpPriceValue_Model.getRowCount()
		){
			var cost_ctrl = this.getElement("unload_price");
			var quant = this.getElement("quant").getValue();
			while(this.m_pumpPriceValue_Model.getNextRow()){
				if(
				(this.m_pumpPriceValue_Model.getFieldValue("quant_from")>=quant&&
				this.m_pumpPriceValue_Model.getFieldValue("quant_to")<=quant)
				||this.m_pumpPriceValue_Model.getFieldValue("price_fixed")
				){
					var cost = this.m_pumpPriceValue_Model.getFieldValue("price_fixed");
					cost = cost? cost : (this.m_pumpPriceValue_Model.getFieldValue("price_m")*quant);
					cost_ctrl.setValue(cost);					
					break;
				}
			}
		}
		this.recalcTotal();
	}
}

OrderCalc_View.prototype.onSelectPumpVehicle = function(f){
	//read all pump schema
	if(this.getElement("pump_vehicle").isNull())return;
	
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
			debugger
			self.m_pumpPriceValue_Model = resp.getModel("PumpPriceValue_Model");
			self.recalcUnloadCost();
		}
	});
}

OrderCalc_View.prototype.changeSumTotals = function(){
	var field_set = document.getElementById(this.getId()+":sum_totals");
	if(this.m_getPayCash()){
		DOMHelper.delClass(field_set,"hidden");
		this.getElement("destination_price").setValue(this.m_destinationPrice);
		this.recalcUnloadCost();
	}
	else{
		DOMHelper.addClass(field_set,"hidden");
		this.getElement("total").reset();
		this.getElement("destination_price").reset();
		this.getElement("unload_price").reset();
	}
}

