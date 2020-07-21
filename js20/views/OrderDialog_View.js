/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderDialog_View(id,options){	

	options = options || {};
	options.controller = new Order_Controller();
	options.model = (options.models&&options.models.OrderDialog_Model)? options.models.OrderDialog_Model: new OrderDialog_Model();
	
	options.cmdSave = false;

	var app = window.getApp();
	var constants = {"def_order_unload_speed":null,"def_lang":null};
	app.getConstantManager().get(constants);
	
	var role_id = app.getServVar("role_id");
	this.m_readOnly = (role_id=="lab_worker");
	
	var bool_bs_cl = "control-label "+window.getBsCol(5);
	var obj_bs_cl = ("control-label "+window.getBsCol(2));
	
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
		this.addElement(date_time_ctrl);
		
		this.addElement(new OrderTimeSelect(id+":date_time_time",{
			"required":true,
			"value":options.dateTime_time,
			"attrs":{"style":"width:150px;"},
			"inline":true
		}));	
	
		this.addElement(new EditCheckBox(id+":pay_cash",{
			"labelCaption":"Оплата на месте:",
			"className":"",
			"labelClassName":bool_bs_cl,
			"events":{
				"change":function(){
					self.getElement("calc").setPayCash();
				}
			}
		}));	

		this.addElement(new EditCheckBox(id+":payed",{
			"labelCaption":"Оплачено:",
			"className":"",
			"labelClassName":bool_bs_cl
		}));	

		this.addElement(new EditCheckBox(id+":under_control",{
			"labelCaption":"На контроле:",
			"className":"",
			"labelClassName":bool_bs_cl
		}));	
	
		//*****************
		var client_ctrl = new ClientEdit(id+":client",{
			"cmdInsert":true,
			"labelClassName":obj_bs_cl,
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
		
		
		this.addElement(new EditFloat(id+":unload_speed",{
			"labelCaption":"Скорость разгрузки:",
			"value":constants.def_order_unload_speed.getValue(),
			"labelClassName":obj_bs_cl,
			"editContClassName":("input-group "+window.getBsCol(2)),
			"events":{
				"onchange":function(){
					self.getElement("calc").recalcTotal();						
					self.getAvailSpots();				
				},
				"onkeyup":function(e){
					self.getElement("calc").recalcTotal();						
					self.getAvailSpots();
				}
			}			
		}));

		var descr_ac_model = new ModelXML("OrderDescr_Model",{
			"fields":{
				"descr":new FieldString("descr"),
				"phone_cel":new FieldString("phone_cel"),
				//"langs_ref":new FieldJSON("langs_ref"),
				"clients_ref":new FieldJSON("clients_ref")
			}
		})
		
		
		this.addElement(new EditString(id+":descr",{
			"labelCaption":"Прораб:",
			"labelClassName":obj_bs_cl,
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
			"labelClassName":obj_bs_cl,
			"labelCaption":"Телефон:",
		}));
		/*
		this.addElement(new LangEditRef(id+":lang",{
			"labelClassName":obj_bs_cl,
			"value":constants.def_lang.getValue()
		}));	
		*/
		this.addElement(new UserEditRef(id+":user",{
			"labelClassName":obj_bs_cl,
			"labelCaption":"Автор документа:",
			"enabled":(role_id=="owner"),
			"value":new RefType({"keys":{"id":app.getServVar("user_id")},"descr":app.getServVar("user_name"),"dataType":"users"})
		}));
			
		this.addElement(new EditString(id+":comment_text",{
			"labelClassName":obj_bs_cl,			
			"labelCaption":"Комментарий:",
			"maxLength":500
		}));	
		
		this.addElement(new OrderCalc_View(id+":calc",{
			"readOnly":this.m_readOnly,
			"calc":false,
			"getAvailSpots":function(){
				self.getAvailSpots();
			},
			"getPayCash":function(){
				return self.getElement("pay_cash").getValue();
			},
			"dialogContext":this
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
		,new DataBinding({"control":this.getElement("calc").getElement("destination"),"field":this.m_model.getField("destinations_ref")})
		,new DataBinding({"control":this.getElement("calc").getElement("quant")})
		,new DataBinding({"control":this.getElement("unload_speed")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("calc").getElement("concrete_type"),"field":this.m_model.getField("concrete_types_ref")})
		,new DataBinding({"control":this.getElement("calc").getElement("pump_vehicle"),"field":this.m_model.getField("pump_vehicles_ref")})
		,new DataBinding({"control":this.getElement("calc").getElement("unload_type")})
		,new DataBinding({"control":this.getElement("descr")})
		,new DataBinding({"control":this.getElement("phone_cel")})
		//,new DataBinding({"control":this.getElement("lang"),"field":this.m_model.getField("langs_ref")})
		,new DataBinding({"control":this.getElement("user"),"field":this.m_model.getField("users_ref")})
		,new DataBinding({"control":this.getElement("calc").getElement("destination_cost")})
		,new DataBinding({"control":this.getElement("calc").getElement("concrete_cost")})
		,new DataBinding({"control":this.getElement("calc").getElement("unload_price")})
		,new DataBinding({"control":this.getElement("calc").getElement("total")})
	];
	this.setDataBindings(r_bd);
	
	//write
	if(this.m_readOnly){
		this.setWriteBindings([
			new CommandBinding({"control":this.getElement("comment_text")})
		]);
	}
	else{
		this.setWriteBindings([
			new CommandBinding({
				"func":function(pm){
					self.setPublicMethodDateTime(pm);
					if(self.getTotalEditModified()){
						pm.setFieldValue("total_edit",!self.m_model.getFieldValue("total_edit"));
					}
					else{
						pm.unsetFieldValue("total_edit");
					}
				}
			})
			,new CommandBinding({"control":this.getElement("pay_cash")})
			,new CommandBinding({"control":this.getElement("under_control")})
			,new CommandBinding({"control":this.getElement("payed")})
			,new CommandBinding({"control":this.getElement("client"),"fieldId":"client_id"})
			,new CommandBinding({"control":this.getElement("calc").getElement("destination"),"fieldId":"destination_id"})
			,new CommandBinding({"control":this.getElement("calc").getElement("quant")})
			,new CommandBinding({"control":this.getElement("unload_speed")})
			,new CommandBinding({"control":this.getElement("comment_text")})		
			,new CommandBinding({"control":this.getElement("calc").getElement("concrete_type"),"fieldId":"concrete_type_id"})
			,new CommandBinding({"control":this.getElement("calc").getElement("pump_vehicle"),"fieldId":"pump_vehicle_id"})
			,new CommandBinding({"control":this.getElement("calc").getElement("unload_type")})
			,new CommandBinding({"control":this.getElement("descr")})
			,new CommandBinding({"control":this.getElement("phone_cel")})
			//,new CommandBinding({"control":this.getElement("lang"),"fieldId":"lang_id"})
			,new CommandBinding({"control":this.getElement("user"),"fieldId":"user_id"})
			,new CommandBinding({"control":this.getElement("calc").getElement("destination_cost"),"fieldId":"destination_price"})
			,new CommandBinding({"control":this.getElement("calc").getElement("concrete_cost"),"fieldId":"concrete_price"})
			,new CommandBinding({"control":this.getElement("calc").getElement("unload_cost"),"fieldId":"unload_price"})
			,new CommandBinding({"control":this.getElement("calc").getElement("total")})
		]);
	}	
}
extend(OrderDialog_View,ViewObjectAjx);


OrderDialog_View.prototype.onSelectDescr = function(f){
	this.getElement("phone_cel").setValue(f.phone_cel.getValue());
	//this.getElement("lang").setValue(f.langs_ref.getValue());
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
	if(f.quant.getValue()){
		inf = DateHelper.format(f.date_time.getValue(),"d/m/y")+","+f.destinations_ref.getValue().getDescr()+","+f.concrete_types_ref.getValue().getDescr()+","+f.quant.getValue()+"м3";
	}
	else{
		inf = "Еще не брал";
	}
	this.getElement("client").getErrorControl().setValue(inf,"info");
	
	this.setClientId(f.id.getValue());
}


OrderDialog_View.prototype.getAvailSpots = function(){
	this.getElement("avail_time").refresh(
		this.getElement("date_time_date").getValue(),
		this.getElement("calc").getElement("quant").getValue(),
		this.getElement("unload_speed").getValue()
	);
}

OrderDialog_View.prototype.getModified = function(cmd){
	return (
		OrderDialog_View.superclass.getModified.call(this,cmd) || this.getDateModified() || this.getTotalEditModified()
	);
}

OrderDialog_View.prototype.getTotalEditModified = function(pm){
	return (this.getElement("calc").getElement("total").getEditAllowed()!=this.m_model.getFieldValue("total_edit"));
}

OrderDialog_View.prototype.getDateModified = function(pm){
	return (this.getElement("date_time_date").getModified()||this.getElement("date_time_time").getModified());
}

OrderDialog_View.prototype.setPublicMethodDateTime = function(pm){
	if(this.getDateModified()){
		var dt = this.getElement("date_time_date").getValue();
		if(dt){
			dt = DateHelper.dateStart(dt);
			dt = new Date(dt.getTime()+ DateHelper.timeToMS(this.getElement("date_time_time").getValue()));
		}
		pm.setFieldValue("date_time",dt);
	}
	else{
		pm.unsetFieldValue("date_time");
	}
}

OrderDialog_View.prototype.setClientId = function(clientId){
	var dest_ac = this.getElement("calc").getElement("destination").getAutoComplete();
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
	
	var ctrl_calc = this.getElement("calc");
	
	ctrl_calc.getElement("total").setEditAllowed(m.getFieldValue("total_edit"));	
	ctrl_calc.changeUnloadType();
	ctrl_calc.setDestinationPrice(m.getFieldValue("destination_price"),m.getFieldValue("destination_distance"),m.getFieldValue("destination_time_rout"))
	ctrl_calc.setConcretePrice(m.getFieldValue("concrete_price"));
	
	//last modif
	var last_modif_users_ref = m.getFieldValue("last_modif_users_ref");	
	if(last_modif_users_ref&&!last_modif_users_ref.isNull()){
		var id =this.getId();
		document.getElementById(id+":cmd-cont").style = "float:left;";
		DOMHelper.setText(document.getElementById(id+":last_modif_user"), last_modif_users_ref.getDescr());
		DOMHelper.setText(document.getElementById(id+":last_modif_date_time"), DateHelper.format(m.getFieldValue("last_modif_date_time"),"d/m/y H:i"));
	}
	
	if(this.m_readOnly){
		this.setEnabled(false);
		this.getElement("comment_text").setEnabled(true);
		this.getControlOK().setEnabled(true);
	}
}
