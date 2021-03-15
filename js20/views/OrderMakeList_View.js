/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderMakeList_View(id,options){	

	this.m_lowResDevice = (window.getWidthType()=="sm");
	options.templateOptions = options.templateOptions || {};	
	options.templateOptions.showChart = !this.m_lowResDevice;
	options.templateOptions.showGridHeaders = this.m_lowResDevice;
	
	this.m_showProductionSites = !this.m_lowResDevice;
	options.templateOptions.showProductionSites = this.m_showProductionSites;
	
//alert("getWidthType="+window.getWidthType())	
	options.className = "row";
	this.m_refreshMethod = (new Order_Controller()).getPublicMethod("get_make_orders_form");

	var self = this;
	
	this.resetTotals();
	
	var constants = {
		"order_grid_refresh_interval":null,
		"first_shift_start_time":null,
		"day_shift_length":null,
		"order_step_min":null,
		"shift_length_time":"null"
	};
	window.getApp().getConstantManager().get(constants);

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

	//date set
	var init_dt,cond_date;
	if(options.models&&options.models.InitDate&&options.models.InitDate.getNextRow()){			
		var d_s = options.models.InitDate.getFieldValue("dt");
		init_dt = DateHelper.strtotime(d_s);
		//cond_date = d_s.substr(0,10);
	}
	
	options.addElement = function(){

		//plant load control
		if(!this.m_lowResDevice){
			this.addElement(new PlantLoadGraphControl(id+":plant_load_graph",{
				"model":options.models.Graph_Model
			}));
		}
		var per_select = new EditPeriodShift(id+":order_make_filter",{
			"template":window.getApp().getTemplate( ((window.getWidthType()=="sm")? "EditPeriodShiftSM":"EditPeriodShift") ),
			"dateFrom":init_dt,
			"onChange":function(dateTime){
				//self.m_refreshMethod.setFieldValue("date",dateTime);
				
				window.setGlobalWait(true);
				self.refresh(function(){
					window.setGlobalWait(false);
				});
			}
		});
		this.addElement(per_select);	
	
		//var contr = new Order_Controller();
		
		//orders
		var model = options.models.OrderMakeList_Model;
		var grid = new OrderMakeGrid(id+":order_make_grid",{
			"model":options.models.OrderMakeList_Model,
			"periodSelect":per_select,
			"className":"table-bordered table-responsive table-make_order order_make_grid",
			"listView":this,
			"stepMin":constants.order_step_min.getValue(),
			"shiftStart":constants.first_shift_start_time.getValue(),
			"shiftLength":constants.shift_length_time.getValue()
		});
		this.addElement(grid);
		grid.onRefresh = function(){
			self.refresh();
		}
		
		//production sites
		if (this.m_showProductionSites){
			this.addElement(new CementSiloForOrderList_View(id+":production_sites",{
				"model":options.models.CementSiloForOrderList_Model,
				"listView":this
			}));
			this.addElement(new MaterialStoreForOrderList_View(id+":material_stores",{
				"model":options.models.MaterialStoreForOrderList_Model,
				"listView":this
			}));			
		}
				
		//material totals
		var model = options.models.MatTotals_Model;
		this.addElement(new MaterialMakeOrderGrid(id+":mat_totals_grid",{
			"model":model,
			"className":this.TABLE_CLASS,
			"refresh":function(){
				self.refresh();
			}
		}));
		
		//assigning
		this.addElement(new AssignedVehicleList_View(id+":veh_assigning",{
			"models":options.models,
			"shortDescriptions":true,
			"noAutoRefresh":true
		}));
		
		//vehicles
		this.addElement(new VehicleScheduleMakeOrderGrid(id+":veh_schedule_grid",{"model":options.models.VehicleScheduleMakeOrderList_Model}));
		
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
	
	//,"params":{"cond_date":cond_date}
	options.srvEvents = {
		"events":[
			{"id":"Order.insert"}
			,{"id":"Order.update"}
			,{"id":"Order.delete"}
			,{"id":"VehicleScheduleState.insert"}
			,{"id":"VehicleScheduleState.update"}
			,{"id":"VehicleScheduleState.delete"}
			,{"id":"RAMaterialFact.change"}
		]
		,"onEvent": function(json){
			self.srvEventsCallBack(json);
		}
		,"onSubscribed": function(){
			self.setRefreshInterval(self.FORCE_REFRESH_INTERVAL);
		}
		,"onClose": function(message){
			self.setRefreshInterval(self.m_httpRefreshInterval);
		}		
	};
	
	this.m_httpRefreshInterval = constants.order_grid_refresh_interval.getValue()*1000;
	
	OrderMakeList_View.superclass.constructor.call(this,id,options);
		
}
extend(OrderMakeList_View,View);

OrderMakeList_View.prototype.COL_CLIENT_LEN = 20;
OrderMakeList_View.prototype.COL_DEST_LEN = 10;
OrderMakeList_View.prototype.COL_COMMENT_LEN = 15;
OrderMakeList_View.prototype.COL_DESCR_LEN = 15;
OrderMakeList_View.prototype.COL_DRIVER_LEN = 10;
OrderMakeList_View.prototype.COL_PUMP_VEH_LEN = 10;
OrderMakeList_View.prototype.TABLE_CLASS = "table-bordered table-responsive table-striped table-make_order";
OrderMakeList_View.prototype.FORCE_REFRESH_INTERVAL = 30*60*1000;

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
OrderMakeList_View.prototype.refresh = function(callBack){
	this.m_refreshMethod.setFieldValue("date",this.getElement("order_make_filter").getDateFrom());
	var self = this;
	
	this.m_refreshMethod.run({
		"ok":function(resp){					
			self.onRefreshResponse(resp);
			if(callBack)callBack();
		}
	})
}

OrderMakeList_View.prototype.setRefreshInterval = function(v){
	if(this.m_refreshInterval == v){
		return;
	}
console.log("OrderMakeList_View.prototype.setRefreshInterval v="+v)
	this.m_refreshInterval = v;
	if (this.m_refreshTimer!=undefined){		
		console.log("clearing timer")
		window.clearInterval(this.m_refreshTimer);
	}
	if (v>0){
		var self = this;
		this.m_refreshTimer = setInterval(function(){
			self.refresh();
		},v);
	}
}

OrderMakeList_View.prototype.toDOM = function(p){
	
	OrderMakeList_View.superclass.toDOM.call(this,p);
	
	if(!window.getApp().getAppSrv()){
		this.setRefreshInterval(this.m_httpRefreshInterval);
	}
	
	this.showTotals();
}

OrderMakeList_View.prototype.delDOM = function(){
	
	if (this.m_refreshTimer!=undefined){		
		window.clearInterval(this.m_refreshTimer);
	}
	
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

OrderMakeList_View.prototype.onRefreshResponse = function(resp){
	//orders
	//do nothing if locked
	if(resp.modelExists("OrderMakeList_Model")){
		var grid = this.getElement("order_make_grid");
		if(!grid.getLocked()){
			this.resetTotals();
			
			grid.getModel().setData(resp.getModelData("OrderMakeList_Model"));
			grid.onGetData();
		}
	}	
	//chart
	if(resp.modelExists("Graph_Model") && !this.m_lowResDevice){
		this.getElement("plant_load_graph").setModel(resp.getModel("Graph_Model"));
	}
	
	if(this.m_showProductionSites && resp.modelExists("CementSiloForOrderList_Model")){
		this.getElement("production_sites").setData(resp.getModel("CementSiloForOrderList_Model"));
	}

	if(this.m_showProductionSites && resp.modelExists("MaterialStoreForOrderList_Model")){
		this.getElement("material_stores").setData(resp.getModel("MaterialStoreForOrderList_Model"));
	}
	
	//mat totals
	if(resp.modelExists("MatTotals_Model")){
		var grid = this.getElement("mat_totals_grid");
		grid.getModel().setData(resp.getModelData("MatTotals_Model"));
		grid.onGetData();
	}
		
	//assigning
	if(resp.modelExists("AssignedVehicleList_Model")){
		this.getElement("veh_assigning").setData(resp.getModelData("AssignedVehicleList_Model"));
	}
	
	//vehicles
	if(resp.modelExists("VehicleScheduleMakeOrderList_Model")){
		var grid = this.getElement("veh_schedule_grid");
		grid.getModel().setData(resp.getModelData("VehicleScheduleMakeOrderList_Model"));
		grid.onGetData();
	}
	
	//features
	if(resp.modelExists("VehFeaturesOnDateList_Model")){
		var grid = this.getElement("features_grid");
		grid.getModel().setData(resp.getModelData("VehFeaturesOnDateList_Model"));
		grid.onGetData();
	}
		
	//totals
	this.showTotals();
	
}

OrderMakeList_View.prototype.runSpecificUpdateMethod = function(meth){
	var pm = (new Order_Controller()).getPublicMethod(meth);
	pm.setFieldValue("date",this.getElement("order_make_filter").getDateFrom());
	var self = this;
	pm.run({
		"ok":function(resp){
			self.onRefreshResponse(resp);
		}
	});
}

OrderMakeList_View.prototype.srvEventsCallBack = function(json){
	if(json.controllerId=="Order" || json.methodId=="Graph.change"){
		//analyse cond_date!
		this.runSpecificUpdateMethod("get_make_orders_form_ord");
	}
	else if(json.controllerId=="VehicleScheduleState"){
		this.runSpecificUpdateMethod("get_make_orders_form_veh");
	}
	else if(json.controllerId=="RAMaterialFact"){
		this.runSpecificUpdateMethod("get_make_orders_form_mat");
	}
	
}


