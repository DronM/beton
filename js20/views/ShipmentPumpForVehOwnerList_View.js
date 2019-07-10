/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentPumpForVehOwnerList_View(id,options){	

	ShipmentPumpForVehOwnerList_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	var model = options.models.ShipmentPumpForVehOwnerList_Model;
	var contr = new Shipment_Controller();

	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null,"vehicle_owner_accord_from_day":null,"vehicle_owner_accord_to_day":null};
	window.getApp().getConstantManager().get(constants);

	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});

	var cur_d = (DateHelper.time()).getDate();
	var prev_month_acc_allowed = (cur_d>=constants.vehicle_owner_accord_from_day.getValue() && cur_d<=constants.vehicle_owner_accord_to_day.getValue());
	this.m_accDescr = {};

	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
	};
	
	filters.concrete_type = {
		"binding":new CommandBinding({
			"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
				"contClassName":"form-group-filter",
				"labelCaption":"Марка:"
			}),
			"field":new FieldInt("concrete_type_id")}),
		"sign":"e"		
	};	
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["last_ship_id"],
		"readPublicMethod":contr.getPublicMethod("get_pump_list_for_veh_owner"),
		"editInline":false,
		"editWinClass":ShipmentDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage,
			"addCustomCommandsAfter":function(commands){
				commands.push(new ShipmentPumpForVehOwnerCmdSetAgreed(id+":grid:cmd:setPumpAgreed"));
			}			
			//"cmdExport":false
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg"
									}																		
								})
							],
							"sortable":true,
							"sort":"desc"
						})
					
						,new GridCellHead(id+":grid:head:destinations_ref",{
							"value":"Объект",
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref"),
									"form":null,
									"ctrlClass":EditString,
									"searchOptions":{
										"field":(new FieldString("destinations_ref->descr")),
										"searchType":"on_part",
										"typeChange":true
									}
								})
							],
							"sortable":true
						})
										
						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"colAttrs":{"clign":"center"},
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref"),
									"ctrlClass":ConcreteTypeEdit,
									"searchOptions":{
										"field":new FieldInt("concrete_type_id"),
										"searchType":"on_match",
										"typeChange":false
									}									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:pump_vehicles_ref",{
							"value":"Насос",
							"columns":[
								new GridColumnRef({
									"field":model.getField("pump_vehicles_ref"),
									"ctrlClass":PumpVehicleEdit,
									"searchOptions":{
										"field":new FieldInt("pump_vehicle_id"),
										"searchType":"on_match"
									}																										
								})
							],
							"sortable":true
						})						
						,new GridCellHead(id+":grid:head:quant",{
							"value":"Количество",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant")
								})
							]
						})
						,new GridCellHead(id+":grid:head:pump_cost",{
							"value":"Стоим.насос",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("pump_cost")									
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:acc_comment",{
							"value":"Комментарий",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("acc_comment")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:owner_pump_agreed",{
							"value":"Согласование",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"id":model.getField("owner_pump_agreed"),
									"cellOptions":function(column,row){
										var res = {};
										var m = self.getElement("grid").getModel();
										if(m.getFieldValue("owner_pump_agreed")){
											res.value = DateHelper.format(m.getFieldValue("owner_pump_agreed_date_time"),"d/m/y");
										}
										else if(!m.getFieldValue("date_time")){
											res.value = "Не отгружено";
										}
										else{
											var m_dif = ((DateHelper.time()).getMonth() - m.getFieldValue("date_time").getMonth());
											if(m_dif==1 && prev_month_acc_allowed){
												var ctrl = new ButtonCmd(null,{
													"caption":"Согласовать",
													"onClick":function(){
														self.setOwnerAgreed(this);
													}
												});
												ctrl.m_row = row;
												res.elements = [ctrl];
											}
											else if(m_dif<=1){
												if(!self.m_accDescr["m_"+m_dif]){
													var ship_time = m.getFieldValue("date_time");
													self.m_accDescr["m_"+m_dif] = {
														"from":DateHelper.format(
															new Date(ship_time.getFullYear(),ship_time.getMonth()+1,constants.vehicle_owner_accord_from_day.getValue())
															,"d/m/y"
															)
														,"to":DateHelper.format(
															new Date(ship_time.getFullYear(),ship_time.getMonth()+1,constants.vehicle_owner_accord_to_day.getValue())
															,"d/m/y"
															)
													};	
												}
												res.value = "Разрешено с "+self.m_accDescr["m_"+m_dif].from+" до "+self.m_accDescr["m_"+m_dif].to;
											}
										}
										return res;
									}
								})
							]
						})					
					]
				})
			]
		}),
		"foot":new GridFoot(id+"grid:foot",{
			"autoCalc":true,			
			"elements":[
				new GridRow(id+":grid:foot:row0",{
					"elements":[
						new GridCell(id+":grid:foot:total_sp1",{
							"colSpan":"4"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"})
						})
						,new GridCellFoot(id+":grid:foot:tot_pump_cost",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_pump_cost",
							"gridColumn":new GridColumnFloat({"id":"tot_pump_cost"})
						})						
											
						,new GridCell(id+":grid:foot:total_sp3",{
							"colSpan":"1"
						})						
					]
				})		
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ShipmentPumpForVehOwnerList_View,ViewAjxList);

ShipmentPumpForVehOwnerList_View.prototype.setOwnerAgreed = function(btn){
	var row = btn.m_row;
	var val = btn.getValue();
	var keys = CommonHelper.unserialize(row.getAttr("keys"));
	
	var pm = this.getElement("grid").getReadPublicMethod().getController().getPublicMethod("owner_set_pump_agreed");
	pm.setFieldValue("shipment_id",keys.last_ship_id);
	var slef = this;
	pm.run({
		"ok":function(resp){
			slef.getElement("grid").onRefresh(function(){
				window.showTempNote("Отгрузка согласована",null,2000);
			});
		}
	})
	
}
