/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderMakeList_View(id,options){	

	options.className = "row";
	this.m_refreshMethod = (new Order_Controller()).getPublicMethod("get_make_orders_form");

	var self = this;
	
	this.resetTotals();
	
	var constants = {
		"order_grid_refresh_interval":null,
		"first_shift_start_time":null,
		"day_shift_length":null,
		"order_step_min":null
	};
	window.getApp().getConstantManager().get(constants);

	this.m_refreshInterval = constants.order_grid_refresh_interval.getValue()*1000;

	var st_time = constants.first_shift_start_time.getValue();
	var st_time_parts = st_time.split(":");
	var from_h=0,to_h=0;
	if(st_time_parts&&st_time_parts.length){
		from_h = parseInt(st_time_parts[0],10);
	}
	to_h = from_h + parseInt(constants.day_shift_length.getValue(),10);
	this.m_startShiftMS = DateHelper.timeToMS(st_time);
	this.m_endShiftMS = DateHelper.timeToMS((to_h-1).toString()+":59:59");

	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.workHours = from_h+"-"+to_h;
	
	options.addElement = function(){
	
		//plant load control
		if(window.getWidthType()!="sm"){
			this.addElement(new PlantLoadGraphControl(id+":plant_load_graph",{
				"model":options.models.Graph_Model
			}));
		}
		//date set
		var init_dt;
		if(options.models&&options.models.InitDate&&options.models.InitDate.getNextRow()){
			init_dt = DateHelper.strtotime(options.models.InitDate.getFieldValue("dt"));
		}
		var per_select = new EditPeriodShift(id+":order_make_filter",{
			"dateFrom":init_dt,
			"onChange":function(dateTime){
				self.m_refreshMethod.setFieldValue("date",dateTime);
				self.refresh();
			}
		});
		this.addElement(per_select);	
	
		//var contr = new Order_Controller();
		
		//orders
		var model = options.models.OrderMakeList_Model;
		var grid = new OrderMakeGrid(id+":order_make_grid",{
			"models":options.models,
			"periodSelect":per_select,
			"listView":this,
			"stepMin":constants.order_step_min.getValue(),
			"shiftStart":constants.first_shift_start_time.getValue()
		});
		this.addElement(grid);
		grid.onRefresh = function(){
			self.refresh();
		}
		
		//material totals
		var model = options.models.MatTotals_Model;
		this.addElement(new Grid(id+":mat_totals_grid",{
			"model":model,
			"className":this.TABLE_CLASS,
			"attrs":{"style":"width:100%;"},
			"keyIds":["material_id"],
			"readPublicMethod":null,
			"editInline":false,
			"editWinClass":null,
			"commands":null,
			"popUpMenu":null,
			"head":new GridHead(id+":mat_totals_grid:head",{
				"elements":[
					new GridRow(id+"mat_totals_grid:head:row0",{
						"elements":[
							new GridCellHead(id+":mat_totals_grid:head:material_descr",{
								"value":"Материал",
								"columns":[
									new GridColumn({"field":model.getField("material_descr")})
								]
							})
							,new GridCellHead(id+":mat_totals_grid:head:quant_ordered",{
								"value":"Заявлено",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_ordered"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":mat_totals_grid:head:quant_procured",{
								"value":"Приход",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_procured"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":mat_totals_grid:head:quant_balance",{
								"value":"Ост.тек.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_balance"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":mat_totals_grid:head:quant_morn_balance",{
								"value":"Ост.утро",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_morn_balance"),
										"precision":3
									})
								]
							})
						]
					})
				]
			}),
			"pagination":null,
			"autoRefresh":false,
			"refreshInterval":null,
			"rowSelect":false,
			"focus":false,
			"navigate":false,
			"navigateClick":false
		}));
		
		//assigning
		this.addElement(new AssignedVehicleList_View(id+":veh_assigning",{
			"models":options.models,
			"noAutoRefresh":true
		}));
		
		//vehicles
		var model = options.models.VehicleScheduleMakeOrderList_Model;	
		//veh_popup.addButton();
		this.addElement(new GridAjx(id+":veh_schedule_grid",{
			"model":model,
			"className":this.TABLE_CLASS,
			"attrs":{"style":"width:100%;"},
			"readPublicMethod":(new VehicleSchedule_Controller()).getPublicMethod("get_current_veh_list"),
			"editInline":false,
			"editWinClass":null,
			"commands":new GridCmdContainerAjx(id+":grid:cmd",{
				"cmdFilter":false,
				"cmdSearch":false,
				"cmdInsert":false,//new GridCmdInsert(id+":grid:cmd:insert",{"showCmdControl":false})
				"cmdAllCommands":false,
				"cmdExport":false,
				"cmdPrint":false,
				"cmdEdit":false,
				"cmdRefresh":false,
				"cmdDelete":false,
				"cmdCopy":false,
				"filters":null,
				"variantStorage":null,
				"addCustomCommandsAfter":function(commands){
					commands.push(new VehicleScheduleGridCmdSetFree(id+":grid:cmd:setFree",{"showCmdControl":false}));
					commands.push(new VehicleScheduleGridCmdSetOut(id+":grid:cmd:setOut",{"showCmdControl":false}));
					commands.push(new VehicleScheduleGridCmdShowPosition(id+":grid:cmd:showPos",{"showCmdControl":false}));
				}
			}),
			"popUpMenu":new PopUpMenu(),
			"onEventSetCellOptions":function(opts){
				if(opts.gridColumn.getId()=="vehicles_ref"){
					opts.className = opts.className||"";
					var m = this.getModel();
					if(m.getFieldValue("no_tracker")){
						opts.title="Нет оборудования мониторинга";
						opts.className+=(opts.className.length? " ":"")+"no_tracker";
					}
					else if(m.getFieldValue("tracker_no_data")){
						opts.title="Нет сигнала";
						opts.className+=(opts.className.length? " ":"")+"tracker_no_data";
					}
				}				
			},
			"onEventSetRowOptions":function(opts){
				opts.className = opts.className||"";
				var m = this.getModel();
				var veh_state = m.getFieldValue("state");
					
				opts.className+=(opts.className.length? " ":"")+"veh_in_make_list";
				if (m.getFieldValue("is_late")){
					opts.className+=(opts.className.length? " ":"")+"veh_late";
				}
				else{
					opts.className+=(opts.className.length? " ":"")+ "veh_"+veh_state;
				}
				if (m.getFieldValue("is_late_at_dest")){
					opts.className+=(opts.className.length? " ":"")+"veh_late_at_dest";
				}

				if (veh_state=="shift"){
					opts.className+=(opts.className.length? " ":"")+"veh_shift";
				}
				
				//opts.title = "Кликните для отображения местоположения ТС карте";
				
				/*opts.events = opts.events || {};
				opts.events.click = function(e){
					if(e.target.tagName=="TD"){
						self.showVehCurrentPosition(CommonHelper.unserialize(this.getAttr("keys")).id);
					}
				}*/
			},
			
			"head":new GridHead(id+":veh_schedule_grid:head",{
				"elements":[
					new GridRow(id+"veh_schedule_grid:head:row0",{
						"elements":[
							new GridCellHead(id+":veh_schedule_grid:head:vehicles_ref",{
								"value":"Номер",
								"columns":[
									new GridColumnRef({
										"field":model.getField("vehicles_ref"),
										"master":true,
										"detailViewClass":VehicleRun_View,
										"detailViewOptions":{
											"detailFilters":{
												"VehicleRun_Model":[
													{
													"masterFieldId":"id",
													"field":"schedule_id",
													"sign":"e",
													"val":"0"
													}	
												]
											}													
										}										
									})
								]								
							})
							,new GridCellHead(id+":veh_schedule_grid:head:drivers_ref",{
								"value":"Водитель",
								"columns":[
									new GridColumn({
										"field":model.getField("drivers_ref"),
										"formatFunction":function(fields,cell){
											return window.getApp().formatCell(fields.drivers_ref,cell,VehicleScheduleMakeOrderList_View.prototype.COL_DRIVER_LEN);
										}
									})
								]
							})
							,new GridCellHead(id+":veh_schedule_grid:head:owner",{
								"value":"Владелец",
								"columns":[
									new GridColumn({
										"field":model.getField("owner"),
										"formatFunction":function(fields,cell){
											return window.getApp().formatCell(fields.owner,cell,VehicleScheduleMakeOrderList_View.prototype.COL_OWNER_LEN);
										}
									})
								]
							})
							,new GridCellHead(id+":veh_schedule_grid:head:load_capacity",{
								"value":"Гр",
								"title":"Грузоподъемность",
								"colAttrs":{"align":"center"},
								"columns":[
									new GridColumn({"field":model.getField("load_capacity")})
								]
							})
							,new GridCellHead(id+":veh_schedule_grid:head:state",{
								"value":"Сост.",
								"columns":[
									new EnumGridColumn_vehicle_states({"field":model.getField("state")})
								]
							})
							,new GridCellHead(id+":veh_schedule_grid:head:inf_on_return",{
								"value":"Вр.",
								"title":"Время",
								"colAttrs":{"align":"center"},
								"columns":[
									new GridColumn({"field":model.getField("inf_on_return")})
								]
							})
							,new GridCellHead(id+":veh_schedule_grid:head:runs",{
								"value":"Р-сы",
								"title":"Количество рейсов",
								"colAttrs":{"align":"center"},
								"columns":[
									new GridColumn({"field":model.getField("runs")})
								]
							})
							
						]
					})
				]
			}),
			"pagination":null,
			"autoRefresh":false,
			"refreshInterval":null,
			"rowSelect":true,
			"focus":false
			//"navigate":false,
			//"navigateClick":false
		}));
		
		//features_grid		
		var model = options.models.VehFeaturesOnDateList_Model;	
		this.addElement(new Grid(id+":features_grid",{
			"model":model,
			"keyIds":["feature"],
			"className":this.TABLE_CLASS,
			"attrs":{"style":"width:100%;"},
			"readPublicMethod":null,
			"editInline":false,
			"editWinClass":null,
			"commands":null,
			"popUpMenu":null,
			"head":new GridHead(id+":features_grid:head",{
				"elements":[
					new GridRow(id+"features_grid:head:row0",{
						"elements":[
							new GridCellHead(id+":features_grid:head:feature",{
								"value":"Св-во",
								"title":"Свойство ТС",
								"columns":[
									new GridColumn({"field":model.getField("feature")})
								]
							})
							,new GridCellHead(id+":features_grid:head:cnt",{
								"value":"Кол-во",
								"title":"Количество ТС по свойству",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({"field":model.getField("cnt")})
								]
							})
						]
					})
				]
			}),
			"foot":new GridFoot(id+":features_grid:foot",{
				"autoCalc":true,			
				"elements":[
					new GridRow(id+":features_grid:foot:row0",{
						"elements":[
							new GridCell(id+":features_grid:foot:total_sp",{
								"value":"Итого"
							})												
							,new GridCellFoot(id+":features_grid:foot:tot_cnt",{
								"attrs":{"align":"right"},
								"calcOper":"sum",
								"calcFieldId":"cnt",
								"gridColumn":new GridColumnFloat({"id":"tot_cnt"})
							})						
						]
					})		
				]
			}),
			
			"pagination":null,
			"autoRefresh":false,
			"refreshInterval":null,
			"rowSelect":false,
			"focus":false,
			"navigate":false,
			"navigateClick":false
		}));
		
		this.addElement(new Statistics_View(id+":statistics"));
	}
	
	
	OrderMakeList_View.superclass.constructor.call(this,id,options);
		
}
extend(OrderMakeList_View,View);

OrderMakeList_View.prototype.COL_CLIENT_LEN = 15;
OrderMakeList_View.prototype.COL_DEST_LEN = 10;
OrderMakeList_View.prototype.COL_COMMENT_LEN = 15;
OrderMakeList_View.prototype.COL_DESCR_LEN = 10;
OrderMakeList_View.prototype.COL_DRIVER_LEN = 10;
OrderMakeList_View.prototype.TABLE_CLASS = "table-bordered table-responsive table-striped table-make_order";

OrderMakeList_View.prototype.m_orderedTotal;
OrderMakeList_View.prototype.m_restTotal;
OrderMakeList_View.prototype.m_shippedTotal;
OrderMakeList_View.prototype.m_orderedSum;
OrderMakeList_View.prototype.m_orderedDay;
OrderMakeList_View.prototype.m_orderedBeforeNow = 0;
OrderMakeList_View.prototype.m_shippedBeforeNow = 0;
OrderMakeList_View.prototype.m_shippedDayBeforeNow = 0;

OrderMakeList_View.prototype.m_startShiftMS;
OrderMakeList_View.prototype.m_endShiftMS;


/**
 * Все обновляется разом за один запрос из нескольких моделей
 */
OrderMakeList_View.prototype.refresh = function(){
//console.log("OrderMakeList_View.prototype.refresh")
	this.m_refreshMethod.setFieldValue("date",this.getElement("order_make_filter").getDateFrom());
	var self = this;
	
	this.m_refreshMethod.run({
		"ok":function(resp){					
			
			//orders
			//do nothing if locked
			var grid = self.getElement("order_make_grid");
			if(!grid.getLocked()){
				self.resetTotals();
				
				grid.getModel().setData(resp.getModelData("OrderMakeList_Model"));
				grid.onGetData();
			}
			
			//chart
			if(window.getWidthType()!="sm"){
				self.getElement("plant_load_graph").setModel(resp.getModel("Graph_Model"));
			}
			//mat totals
			var grid = self.getElement("mat_totals_grid");
			grid.getModel().setData(resp.getModelData("MatTotals_Model"));
			grid.onGetData();
			
			//assigning
			self.getElement("veh_assigning").setData(resp.getModelData("AssignedVehicleList_Model"));
			
			//vehicles
			var grid = self.getElement("veh_schedule_grid");
			grid.getModel().setData(resp.getModelData("VehicleScheduleMakeOrderList_Model"));
			grid.onGetData();

			//features
			var grid = self.getElement("features_grid");
			grid.getModel().setData(resp.getModelData("VehFeaturesOnDateList_Model"));
			grid.onGetData();
			
			//totals
			self.showTotals();			
		}
	})
}
/*
OrderMakeList_View.prototype.showVehCurrentPosition = function(vehicleScheduleId){
	var m = this.getElement("veh_schedule_grid").getModel();
	var veh_id;
	m.reset();
	while(m.getNextRow()){
		if(m.getFieldValue("id")==vehicleScheduleId){
			veh_id = m.getFieldValue("vehicles_ref").getKey("id");
			break;
		}
	}
	
	if(!veh_id)return;
	
	var self = this;
	
	var win_w = $( window ).width();
	var h = $( window ).height()-20;//win_w/3*2;
	var left = win_w/3;
	var w = win_w/3*2;//left - 20;
	
	this.m_mapForm = new WindowForm({
		"id":"MapForm",
		"height":h,
		"width":w,
		"left":left,
		"top":10,
		"URLParams":"t=Map&v=Child",
		"name":"Map",
		"params":{
			"editViewOptions":{
				"vehicle":new RefType({"keys":{"id":veh_id}})	
			}
		},
		"onClose":function(){
			self.m_mapForm.close();
			delete self.m_mapForm;			
		}
	});
	this.m_mapForm.open();

}
*/
OrderMakeList_View.prototype.toDOM = function(p){
	OrderMakeList_View.superclass.toDOM.call(this,p);
	
	this.showTotals();
	
	var self = this;
	this.m_timer = setInterval(function(){
		self.refresh();
	}, this.m_refreshInterval);
	
}

OrderMakeList_View.prototype.delDOM = function(){
	clearInterval(this.m_timer);
	
	OrderMakeList_View.superclass.delDOM.call(this);
	
}

OrderMakeList_View.prototype.setTotalVal = function(id,v){
	var n = document.getElementById(id);
	if(n)n.value=v;
}

OrderMakeList_View.prototype.showTotals = function(){
	var n = DateHelper.time();
	var dif_sec = (n.getTime() - (DateHelper.getStartOfShift(n)).getTime())/1000;
	//console.log("dif_sec="+dif_sec)
	this.setTotalVal("totOrdered",this.m_orderedTotal.toFixed(2));
	this.setTotalVal("totShipped",this.m_shippedTotal.toFixed(2));
	this.setTotalVal("totBalance",(this.m_orderedTotal-this.m_shippedTotal).toFixed(2));
	this.setTotalVal("totEfficiency",(Math.round((this.m_shippedBeforeNow-this.m_orderedBeforeNow)*100)/100).toFixed(2));
	this.setTotalVal("totDayVelocity",(Math.round(this.m_orderedDay/13*100)/100).toFixed(2));
	this.setTotalVal("totCurVelocity",(Math.round(this.m_shippedDayBeforeNow/dif_sec*60*60*100)/100).toFixed(2));
	this.setTotalVal("totOrderedDay",this.m_orderedDay.toFixed(2));

}

OrderMakeList_View.prototype.resetTotals = function(){
	this.m_orderedTotal = 0;
	this.m_restTotal = 0;
	this.m_shippedTotal = 0;
	this.m_orderedSum = 0;
	this.m_orderedDay = 0;
	this.m_orderedBeforeNow = 0;
	this.m_shippedBeforeNow = 0;
	this.m_shippedDayBeforeNow = 0;
}
