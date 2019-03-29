/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderDialog_View(id,options){	

	options = options || {};
	options.controller = new Order_Controller();
	options.model = options.models.OrderDialog_Model;

	var app = window.getApp();
	var constants = {"def_order_unload_speed":null,"def_lang":null};
	app.getConstantManager().get(constants);
	
	var role_id = app.getServVar("role_id");
	var bool_bs_cl = "control-label "+window.getBsCol(4);
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new AvailOrderTimeControl(id+":avail_time",{
			"controller":options.controller,
			"onSetTime":function(newTime){
				self.getElement("date_time_time").setValue(DateHelper.format(newTime,"H:i"));
			},
			"onSetSpeed":function(newSpeed){
				self.getElement("unload_speed").setValue(Math.round(newSpeed,2));
			}		
		}));
	
	
		this.addElement(new EditString(id+":number",{
			"enabled":false,
			"attrs":{"style":"width:150px;"},
			"inline":true,
			"cmdClear":false
		}));

		var date_time_ctrl = new EditDate(id+":date_time_date",{
			"required":true,
			"value":options.dateTime_date? options.dateTime_date : DateHelper.time(),
			"attrs":{"style":"width:150px;"},
			"inline":true,
			"cmdClear":false,			
			"onSelect":function(){
				self.getAvailSpots();
			},			
			"events":{
				"onkeyup":function(e){
					self.getAvailSpots();
				}
			}
		});	
		/*
		this.m_dateTimeGetValue = date_time_ctrl.getValue;
		date_time_ctrl.getValue = function(){
			var v = self.m_dateTimeGetValue.call(this);
			if(v){
				var offset = new Date().getTimezoneOffset();
				v = new Date(v.getFullYear(), v.getMonth(), v.getDate(), 0, 0,0,self.getElement("date_time_time").getValue()+offset*1000);
			}
			return v;
		}
		*/
		this.addElement(date_time_ctrl);
		
		this.addElement(new OrderTimeSelect(id+":date_time_time",{
			"required":true,
			"value":options.dateTime_time,
			"attrs":{"style":"width:150px;"},
			"inline":true
		}));	
	
		this.addElement(new EditCheckBox(id+":pay_cash",{
			"labelCaption":"Оплата на месте:",
			//"className":"",
			"labelClassName":bool_bs_cl,
			"events":{
				"change":function(){
					self.changeSumTotals();
				}
			}
		}));	

		this.addElement(new EditCheckBox(id+":payed",{
			"labelCaption":"Оплачено:",
			//"className":"",
			"labelClassName":bool_bs_cl
		}));	

		this.addElement(new EditCheckBox(id+":under_control",{
			"labelCaption":"На контроле:",
			//"className":"",
			"labelClassName":bool_bs_cl
		}));	
	
		//*****************
		var client_ctrl = new ClientEdit(id+":client",{
			"cmdInsert":true,
			"labelClassName":("control-label "+window.getBsCol(2)),
			"acPublicMethodId":"complete_for_order",
			"acModel":new OrderClient_Model(),
			"onSelect":function(f){
				self.onSelectClient(f);
			},
			"focused":true,
			"required":true,
			"onClear":function(){
				self.getElement("client").getErrorControl().setValue("","info");
			}			
		});
		this.m_clientResetKeys = client_ctrl.resetKeys;
		client_ctrl.resetKeys = function(){
			self.m_clientResetKeys.call(self.getElement("client"));
			self.setClientId(null);
		}
		this.addElement(client_ctrl);		
		
		
		this.addElement(new DestinationEdit(id+":destination",{
			"labelClassName":("control-label "+window.getBsCol(2)),
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
			"labelClassName":("control-label "+window.getBsCol(5)),
			"editContClassName":("input-group "+window.getBsCol(7)),
			"events":{
				"onchange":function(){
					self.recalcTotal();						
					self.getAvailSpots();				
				},
				"onkeyup":function(e){
					self.recalcTotal();						
					self.getAvailSpots();
				}
			}			
		}));

		this.addElement(new EditFloat(id+":unload_speed",{
			"labelCaption":"Скорость разгрузки:",
			"value":constants.def_order_unload_speed.getValue(),
			"labelClassName":("control-label "+window.getBsCol(5)),
			"editContClassName":("input-group "+window.getBsCol(7)),
			"events":{
				"onchange":function(){
					self.recalcTotal();						
					self.getAvailSpots();				
				},
				"onkeyup":function(e){
					self.recalcTotal();						
					self.getAvailSpots();
				}
			}			
		}));

		this.addElement(new ConcreteTypeEdit(id+":concrete_type",{			
			"labelClassName":("control-label "+window.getBsCol(5)),
			"editContClassName":("input-group "+window.getBsCol(7)),
			"onSelect":function(f){
				self.onSelectConcrete(f);
			},
			"required":true
		}));	

		this.addElement(new Enum_unload_types(id+":unload_type",{
			"labelCaption":"Вид насоса:",
			"labelClassName":("control-label "+window.getBsCol(5)),
			"editContClassName":("input-group "+window.getBsCol(7)),			
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
			"labelClassName":("control-label "+window.getBsCol(5)),
			"editContClassName":("input-group "+window.getBsCol(7)),
			"onSelect":function(f){
				self.onSelectPumpVehicle(f);
			}
			
		}));	
		
		var descr_ac_model = new ModelXML("OrderDescr_Model",{
			"fields":{
				"descr":new FieldString("descr"),
				"phone_cel":new FieldString("phone_cel"),
				"langs_ref":new FieldJSON("langs_ref"),
				"clients_ref":new FieldJSON("clients_ref")
			}
		})
		
		
		this.addElement(new EditString(id+":descr",{
			"labelCaption":"Прораб:",
			"maxLength":500,
			"cmdAutoComplete":true,
			"acMinLengthForQuery":0,
			"acController":options.controller,
			"acModel":descr_ac_model,
			"acPublicMethod":options.controller.getPublicMethod("complete_descr"),
			"acPatternFieldId":"descr",
			"acKeyFields":[descr_ac_model.getField("descr")],
			"acDescrFields":[descr_ac_model.getField("descr")],
			"acICase":"1",
			"acMid":"1",
			"acEnabled":false,			
			"onSelect":function(f){
				self.onSelectDescr(f);
			},
			"onClear":function(){
				self.getElement("phone_cel").reset();
			}						
			
		}));

		this.addElement(new EditPhone(id+":phone_cel",{
			"labelCaption":"Телефон:",
		}));

		this.addElement(new LangEditRef(id+":lang",{
			"value":constants.def_lang.getValue()
		}));	

		this.addElement(new UserEditRef(id+":user",{
			"labelCaption":"Автор документа:",
			"enabled":(role_id=="owner"),
			"value":new RefType({"keys":{"id":app.getServVar("user_id")},"descr":app.getServVar("user_name"),"dataType":"users"}),
			"labelClassName":("control-label "+window.getBsCol(2))
		}));
			
		this.addElement(new EditString(id+":comment_text",{
			"labelCaption":"Комментарий:",
			"maxLength":500,
			"labelClassName":("control-label "+window.getBsCol(2))
		}));

		this.addElement(new EditMoney(id+":destination_price",{
			"labelCaption":"Доставка:",
			"value":0,
			"events":{
				"change":function(){
					self.recalcTotal();
				}
			}			
		}));
		this.addElement(new EditMoney(id+":unload_price",{
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
			"labelCaption":"Всего:",
			"value":0,
			"enabled":false
		}));
	
	
	}
	
	OrderDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("number")})
		,new DataBinding({"control":this.getElement("date_time_date"),"field":this.m_model.getField("date_time")})
		,new DataBinding({"control":this.getElement("date_time_time"),"field":this.m_model.getField("date_time")})
		,new DataBinding({"control":this.getElement("pay_cash")})
		,new DataBinding({"control":this.getElement("under_control")})
		,new DataBinding({"control":this.getElement("payed")})
		,new DataBinding({"control":this.getElement("client"),"field":this.m_model.getField("clients_ref")})
		,new DataBinding({"control":this.getElement("destination"),"field":this.m_model.getField("destinations_ref")})
		,new DataBinding({"control":this.getElement("quant")})
		,new DataBinding({"control":this.getElement("unload_speed")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("concrete_type"),"field":this.m_model.getField("concrete_types_ref")})
		,new DataBinding({"control":this.getElement("pump_vehicle"),"field":this.m_model.getField("pump_vehicles_ref")})
		,new DataBinding({"control":this.getElement("unload_type")})
		,new DataBinding({"control":this.getElement("descr")})
		,new DataBinding({"control":this.getElement("phone_cel")})
		,new DataBinding({"control":this.getElement("lang"),"field":this.m_model.getField("langs_ref")})
		,new DataBinding({"control":this.getElement("user"),"field":this.m_model.getField("users_ref")})
		,new DataBinding({"control":this.getElement("destination_price")})
		,new DataBinding({"control":this.getElement("total")})
		
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"func":function(pm){
			self.setPublicMethodDateTime(pm);
		}})
		,new CommandBinding({"control":this.getElement("pay_cash")})
		,new CommandBinding({"control":this.getElement("under_control")})
		,new CommandBinding({"control":this.getElement("payed")})
		,new CommandBinding({"control":this.getElement("client"),"fieldId":"client_id"})
		,new CommandBinding({"control":this.getElement("destination"),"fieldId":"destination_id"})
		,new CommandBinding({"control":this.getElement("quant")})
		,new CommandBinding({"control":this.getElement("unload_speed")})
		,new CommandBinding({"control":this.getElement("comment_text")})		
		,new CommandBinding({"control":this.getElement("concrete_type"),"fieldId":"concrete_type_id"})
		,new CommandBinding({"control":this.getElement("pump_vehicle"),"fieldId":"pump_vehicle_id"})
		,new CommandBinding({"control":this.getElement("unload_type")})
		,new CommandBinding({"control":this.getElement("descr")})
		,new CommandBinding({"control":this.getElement("phone_cel")})
		,new CommandBinding({"control":this.getElement("lang"),"fieldId":"lang_id"})
		,new CommandBinding({"control":this.getElement("user"),"fieldId":"user_id"})
		,new CommandBinding({"control":this.getElement("destination_price")})
		,new CommandBinding({"control":this.getElement("total")})
	]);
	
}
extend(OrderDialog_View,ViewObjectAjx);

OrderDialog_View.prototype.m_shipQuantForCostGrade_Model;

OrderDialog_View.prototype.changeUnloadType = function(){
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

OrderDialog_View.prototype.recalcUnloadCost = function(){
//console.log("OrderDialog_View.prototype.recalcUnloadCost")
	if(this.getElement("pay_cash").getValue()){
		if(!this.getElement("pump_vehicle").isNull()
		&&self.m_pumpPriceValue_Model
		&&self.m_pumpPriceValue_Model.getRowCount()
		){
			var cost_ctrl = this.getElement("unload_price");
			var quant = this.getElement("quant").getValue();
			while(self.m_pumpPriceValue_Model.getNextRow()){
				if(
				self.m_pumpPriceValue_Model.getFieldValue("quant_from")>=quant&&
				self.m_pumpPriceValue_Model.getFieldValue("quant_to")<=quant
				){
					var cost = self.m_pumpPriceValue_Model.getFieldValue("price_fixed");
					cost = cost? cost : (self.m_pumpPriceValue_Model.getFieldValue("price_m")*quant);
					cost_ctrl.setValue(cost);					
					break;
				}
			}
		}
		this.recalcTotal();
	}
}

OrderDialog_View.prototype.onSelectPumpVehicle = function(f){
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
			self.m_pumpPriceValue_Model = resp.getModel("PumpPriceValue_Model");
			self.recalcUnloadCost();
		}
	});
}

OrderDialog_View.prototype.onSelectDestination = function(f){
	if(f)
		this.onSelectDestinationCont(f.price.getValue(),f.distance.getValue(),f.time_route.getValue());
}

OrderDialog_View.prototype.onSelectDestinationCont = function(price,distance,timeRout){
//console.log("OrderDialog_View.prototype.onSelectDestination")
	this.m_destinationPrice = parseFloat(price);
	
	var dest_inf = "";
	if (!this.getElement("destination").isNull()){
		dest_inf = "Расстояние.:"+distance+" км."+
			",время:"+DateHelper.format(timeRout,"H:i")+
			",цена:"+(this.m_destinationPrice.toFixed(2))+"руб.";
	}	
	this.getElement("destination").getErrorControl().setValue(dest_inf,"info");
	
	if(this.getElement("pay_cash").getValue()){
		this.getElement("destination_price").setValue(this.m_destinationPrice);
		this.recalcTotal();
	}	
}

OrderDialog_View.prototype.onSelectDescr = function(f){
	this.getElement("phone_cel").setValue(f.phone_cel.getValue());
	this.getElement("lang").setValue(f.langs_ref.getValue());
}

OrderDialog_View.prototype.onSelectClient = function(f){
	var ctrl;
	ctrl = this.getElement("descr");
	if(!ctrl.isNull()){
		ctrl.setValue(f.descr.getValue());
	}
	ctrl = this.getElement("phone_cel");
	if(!ctrl.isNull()){
		ctrl.setValue(f.phone_cel.getValue());
	}
	var inf;
	//console.log("onSelectClient ")
	//console.dir(f)
	if(f.quant.getValue()){
		inf = DateHelper.format(f.date_time.getValue(),"d/m/y")+","+f.destinations_ref.getValue().getDescr()+","+f.concrete_types_ref.getValue().getDescr()+","+f.quant.getValue()+"м3";
	}
	else{
		inf = "Еще не брал";
	}
	this.getElement("client").getErrorControl().setValue(inf,"info");
	
	this.setClientId(f.id.getValue());
}

OrderDialog_View.prototype.changeSumTotals = function(){
	var field_set = document.getElementById(this.getId()+":sum_totals");
	if(this.getElement("pay_cash").getValue()){
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
OrderDialog_View.prototype.onSelectConcrete = function(f){
//console.log("OrderDialog_View.prototype.onSelectConcrete")
	this.m_concretePrice = parseFloat(f.price.getValue());
	var inf = this.m_concretePrice? ("Стоимость: "+(this.m_concretePrice).toFixed(2)+" руб/м3"):"";
	this.getElement("concrete_type").getErrorControl().setValue(inf,"info");
	
	this.recalcTotal();
}

OrderDialog_View.prototype.recalcTotalCont = function(){		
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

OrderDialog_View.prototype.recalcTotal = function(){		
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

OrderDialog_View.prototype.getAvailSpots = function(){
	this.getElement("avail_time").refresh(
		this.getElement("date_time_date").getValue(),
		this.getElement("quant").getValue(),
		this.getElement("unload_speed").getValue()
	);
}

OrderDialog_View.prototype.setPublicMethodDateTime = function(pm){
	if(this.getElement("date_time_date").getModified()||this.getElement("date_time_time").getModified()){
	
		var dt = this.getElement("date_time_date").getValue();
		if(dt){
			dt = DateHelper.dateStart(dt);
			dt = new Date(dt.getTime()+ DateHelper.timeToMS(this.getElement("date_time_time").getValue()));
		}
		pm.setFieldValue("date_time",dt);
	}
}

OrderDialog_View.prototype.setClientId = function(clientId){
	var dest_ac = this.getElement("destination").getAutoComplete();
	var descr_ac = this.getElement("descr").getAutoComplete();
	if(clientId){
		descr_ac.getPublicMethod().setFieldValue("client_id",clientId);
		
		dest_ac.getPublicMethod().setFieldValue("client_id",clientId);
		
	}
	else{
		descr_ac.getPublicMethod().getField("client_id").resetValue();
		
		dest_ac.getPublicMethod().getField("client_id").resetValue();
	}
	
	descr_ac.setEnabled((clientId!==null));
}

OrderDialog_View.prototype.onGetData = function(resp,cmd){
	OrderDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	var m = this.getModel();

	var f = m.getField("clients_ref");
	if(!f.isNull()&&f.getValue()){
		this.setClientId(f.getValue().getKey());
	}
	
	this.getElement("total").setEditAllowed(m.getFieldValue("total_edit"));
	
	this.changeUnloadType();
	this.onSelectDestinationCont(m.getFieldValue("destination_price"),m.getFieldValue("destination_distance"),m.getFieldValue("destination_time_rout"))
}
