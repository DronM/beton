/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderMakeForLabList_View(id,options){	

	options.templateOptions = options.templateOptions || {};	

	options.className = "row";
	this.m_refreshMethod = (new Order_Controller()).getPublicMethod("get_make_orders_for_lab_form");

	var self = this;
	
	var constants = {
		"order_grid_refresh_interval":null,
		"first_shift_start_time":null,
		"day_shift_length":null,
		"order_step_min":null,
		"shift_length_time":"null"
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
		
		var init_dt;
		if(options.models&&options.models.InitDate&&options.models.InitDate.getNextRow()){
			init_dt = DateHelper.strtotime(options.models.InitDate.getFieldValue("dt"));
		}
		
		var per_select = new EditPeriodShift(id+":order_make_filter",{
			"template":window.getApp().getTemplate( ((window.getWidthType()=="sm")? "EditPeriodShiftSM":"EditPeriodShift") ),
			"dateFrom":init_dt,
			"onChange":function(dateTime){
				self.m_refreshMethod.setFieldValue("date",dateTime);
				self.refresh();
			}
		});
		this.addElement(per_select);	
			
		//orders
		var model = options.models.OrderMakeForLabList_Model;
		var grid = new OrderMakeGrid(id+":order_make_grid",{
			"model":options.models.OrderMakeForLabList_Model,
			"className":"table-bordered table-responsive table-make_order order_make_grid",
			"periodSelect":per_select,
			"listView":this,
			"stepMin":constants.order_step_min.getValue(),
			"shiftStart":constants.first_shift_start_time.getValue(),
			"shiftLength":constants.shift_length_time.getValue()
		});
		this.addElement(grid);
		grid.onRefresh = function(){
			self.refresh();
		}
		
		//assigning
		this.addElement(new AssignedVehicleList_View(id+":veh_assigning",{
			"models":options.models,
			"shortDescriptions":true,
			"noAutoRefresh":true
		}));
		
		//material totals
		var model = options.models.MatTotals_Model;
		this.addElement(new MaterialMakeOrderGrid(id+":mat_totals_grid",{
			"model":model,
			"className":this.TABLE_CLASS
		}));
		
		//vehicles
		this.addElement(new VehicleScheduleMakeOrderGrid(id+":veh_schedule_grid",{"model":options.models.VehicleScheduleMakeOrderList_Model}));		
		
		//lab enties 30 days
		var model = options.models.LabEntry30DaysList_Model;
		this.addElement(new GridAjx(id+":lab_entry_grid",{
			"model":model,
			"keyIds":["concrete_type_id"],
			"controller":new LabEntry_Controller(),
			"className":"table table-bordered table-responsive table-striped LabEntry30Days_grid",
			"editInline":false,
			"editWinClass":null,
			"commands":null,		
			"popUpMenu":null,
			"navigate":false,
			"navigateClick":false,
			"navigateMouse":false,
			"lastRowFooter":true,
			"onEventSetRowOptions":function(opts){
				opts.className = opts.className||"";
				if(this.getModel().getFieldValue("need_cnt")>0){
					opts.className+= (opts.className.length? " ":"")+"need";
				}
				var ct_id = this.getModel().getFieldValue("concrete_type_id");
				if(ct_id){
					opts.events = opts.events || {};
					opts.events.click = (function(concreteTypeId){
						return function(){
							self.openLabEntryForm(concreteTypeId);
						}
					})(ct_id);
				}
			},			
			"head":new GridHead(id+":lab_entry_grid:head",{
				"elements":[
					new GridRow(id+":lab_entry_grid:head:row0",{
						"elements":[
							new GridCellHead(id+":lab_entry_grid:head:concrete_type_descr",{
								"value":"Марка",
								"columns":[
									new GridColumn({"field":model.getField("concrete_type_descr")})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:cnt",{
								"value":"Всего машин",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({"field":model.getField("cnt")})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:day_cnt",{
								"value":"Всего по бдн.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({
										"field":model.getField("day_cnt")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:selected_cnt",{
								"value":"Отбор бдн.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({
										"field":model.getField("selected_cnt")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:need_cnt",{
								"value":"Надо еще",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({
										"field":model.getField("need_cnt")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:ok",{
								"value":"ok",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({
										"field":model.getField("ok")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:p7",{
								"value":"p7",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({
										"field":model.getField("p7")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:p28",{
								"value":"p28",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumn({
										"field":model.getField("p28")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:selected_cnt2",{
								"value":"Кол-во",
								"colAttrs":{"align":"right","class":"prev_p"},
								"columns":[
									new GridColumn({
										"field":model.getField("selected_cnt2")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:ok2",{
								"value":"ok",
								"colAttrs":{"align":"right","class":"prev_p"},
								"columns":[
									new GridColumn({
										"field":model.getField("ok2")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:p72",{
								"value":"p7",
								"colAttrs":{"align":"right","class":"prev_p"},
								"columns":[
									new GridColumn({
										"field":model.getField("p72")
									})
								]
							})
							,new GridCellHead(id+":lab_entry_grid:head:p282",{
								"value":"p28",
								"colAttrs":{"align":"right","class":"prev_p"},
								"columns":[
									new GridColumn({
										"field":model.getField("p282")
									})
								]
							})
							
						]
					})
				]
			}),
			"pagination":null,				
			"autoRefresh":false,
			"refreshInterval":0,
			"rowSelect":false,
			"focus":false
		}));
		
	}
	
	
	OrderMakeForLabList_View.superclass.constructor.call(this,id,options);
		
}
extend(OrderMakeForLabList_View,View);

OrderMakeForLabList_View.prototype.TABLE_CLASS = "table-bordered table-responsive table-striped table-make_order";
OrderMakeForLabList_View.prototype.COL_CLIENT_LEN = 20;
OrderMakeForLabList_View.prototype.COL_DEST_LEN = 10;
OrderMakeForLabList_View.prototype.COL_COMMENT_LEN = 15;
OrderMakeForLabList_View.prototype.COL_DESCR_LEN = 15;
OrderMakeForLabList_View.prototype.COL_DRIVER_LEN = 10;
OrderMakeForLabList_View.prototype.COL_PUMP_VEH_LEN = 10;

OrderMakeForLabList_View.prototype.m_startShiftMS;
OrderMakeForLabList_View.prototype.m_endShiftMS;


/**
 * Все обновляется разом за один запрос из нескольких моделей
 */
OrderMakeForLabList_View.prototype.refresh = function(){
//console.log("OrderMakeForLabList_View.prototype.refresh")
	this.m_refreshMethod.setFieldValue("date",this.getElement("order_make_filter").getDateFrom());
	var self = this;
	
	this.m_refreshMethod.run({
		"ok":function(resp){					
			
			//orders
			//do nothing if locked
			var grid = self.getElement("order_make_grid");
			if(!grid.getLocked()){
				
				grid.getModel().setData(resp.getModelData("OrderMakeForLabList_Model"));
				grid.onGetData();
			}

			//materials
			var grid = self.getElement("mat_totals_grid");
			grid.getModel().setData(resp.getModelData("MatTotals_Model"));
			grid.onGetData();
			
			//assigning
			self.getElement("veh_assigning").setData(resp.getModelData("AssignedVehicleList_Model"));
			
			//vehicles
			var grid = self.getElement("veh_schedule_grid");
			grid.getModel().setData(resp.getModelData("VehicleScheduleMakeOrderList_Model"));
			grid.onGetData();

		}
	})
}

OrderMakeForLabList_View.prototype.enableRefreshing = function(v){
	if(v){
		var self = this;
		this.m_timer = setInterval(function(){
			self.refresh();
		}, this.m_refreshInterval);
	}
	else if(this.m_timer){
		clearInterval(this.m_timer);
	}
}

OrderMakeForLabList_View.prototype.toDOM = function(p){
	OrderMakeForLabList_View.superclass.toDOM.call(this,p);
	
	this.enableRefreshing(true);
}

OrderMakeForLabList_View.prototype.delDOM = function(){
	this.enableRefreshing(false);
	
	OrderMakeForLabList_View.superclass.delDOM.call(this);
	
}

OrderMakeForLabList_View.prototype.openLabEntryForm = function(concreteTypeId){
	var win_w = $( window ).width();
	var h = $( window ).height()-20;//win_w/3*2;
	var left = win_w/3;
	var w = win_w/3*2;//left - 20;
	
	var constants = {"lab_days_for_avg":null};
	window.getApp().getConstantManager().get(constants);
	
	var cur_d = DateHelper.time();
	var from_d = (new FieldDateTime("from",{"value":new Date(cur_d.getTime()-constants.lab_days_for_avg.getValue()*24*60*60*1000)})).getValueXHR();
	var to_d = (new FieldDateTime("to",{"value":cur_d})).getValueXHR();
	
	var filter = new VariantStorage_Model();
	filter.setFieldValue("user_id",0);
	filter.setFieldValue("storage_name","LabEntryList");
	filter.setFieldValue("variant_name","LabEntryList");
	filter.setFieldValue("filter_data",{
		"period":{
			"value":{"period":"all"},
			"bindings":[
				{"field":"start_time","sign":"ge","value":from_d}
				,{"field":"start_time","sign":"le","value":to_d}
			]
		},
		"concrete_type":{
			"field":"concrete_type_id","sign":"e","value":new RefType({"keys":{"id":concreteTypeId},"descr":""})
		}
	});
	filter.recInsert();
	filter.getRow(0);
	
	this.m_labForm = new WindowForm({
		"id":"labForm",
		"height":h,
		"width":w,
		"left":left,
		"top":10,
		"URLParams":"c=LabEntry_Controller&f=get_list&t=LabEntryList&v=Child&cond_fields=date_time,date_time,concrete_type_id&cond_sgns=ge,le,e&cond_vals="+from_d+","+to_d+","+concreteTypeId,
		"name":"labForm",
		"params":{
			"editViewOptions":{				
				"variantStorage":{
					"name":"LabEntryList",
					"model":filter
				}
				/*
				"detailFilters":{
					"LabEntryList_Model":[
					{"field":"concrete_type_id",
					"sign":"e",
					"val":concreteTypeId
					}
					,{"field":"date_time",
					"sign":"ge",
					"val":from_d
					}
					,{"field":"date_time",
					"sign":"le",
					"val":to_d
					}
				
					]
				}		
				*/
			}
		},
		"onClose":function(){
			self.m_labForm.close();
			delete self.m_labForm;			
		}
	});
	this.m_labForm.open();
	
}

