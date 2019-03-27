/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function VehicleScheduleList_View(id,options){	

	var model = options.models.VehicleScheduleList_Model;
	var contr = new VehicleSchedule_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	
	options.addElement = function(){
		//date set
		var per_select = new EditPeriodShift(id+":schedule_date",{
			"dateFormat":"Y-m-d",
			"filters":[
				{"field":"schedule_date",
				"sign":"e",
				"val":""
				}
			]
		});
		this.addElement(per_select);
		/*
		var filters = {
			"schedule_date":{
				"binding":new CommandBinding({
					"control":new EditDate(id+":filter-ctrl-schedule_date",{
						"contClassName":"form-group-filter",
						"labelCaption":"Дата:",
						"value":DateHelper.time()
					}),
					"field":new FieldDate("schedule_date")}),

				"sign":"e"		
			}
		
			,"driver":{
				"binding":new CommandBinding({
					"control":new DriverEditRef(id+":filter-ctrl-driver",{
						"contClassName":"form-group-filter",
						"labelCaption":"Водитель:"
					}),
					"field":new FieldInt("driver_id")}),
				"sign":"e"		
			}
			,"vehicle":{
				"binding":new CommandBinding({
					"control":new VehicleEdit(id+":filter-ctrl-vehicle",{
						"contClassName":"form-group-filter",
						"labelCaption":"ТС:"
					}),
					"field":new FieldInt("vehicle_id")}),
				"sign":"e"		
			}
		
		};
		*/
		var popup_menu = new PopUpMenu();
		var pagClass = window.getApp().getPaginationClass();
		var grid = new GridAjx(id+":grid",{
			"model":model,
			"controller":contr,
			"editInline":false,
			"editWinClass":VehicleScheduleDialog_Form,
			"insertViewOptions":function(){
				return {"schedule_date":self.getElement("schedule_date").getDateFrom()};
			},
			"commands":new GridCmdContainerAjx(id+":grid:cmd",{
				"cmdFilter":false,
				"cmdSearch":false,
				"filters":null,
				"variantStorage":null,
				"addCustomCommandsAfter":function(commands){
					commands.push(new VehicleScheduleGridCmdSetFree(id+":grid:cmd:setFree"));
					commands.push(new VehicleScheduleGridCmdSetOut(id+":grid:cmd:setOut"));
				}
			}),
			"popUpMenu":popup_menu,
			"head":new GridHead(id+"-grid:head",{
				"elements":[
					new GridRow(id+":grid:head:row0",{
						"elements":[
							new GridCellHead(id+":grid:head:schedule_date",{
								"value":"Дата",
								"columns":[
									new GridColumnDate({
										"field":model.getField("schedule_date")
									})
								]
							})
							,new GridCellHead(id+":grid:head:state_date_time",{
								"value":"Время",
								"columns":[
									new GridColumnDate({
										"field":model.getField("state_date_time"),
										"dateFormat":"H:i"
									})
								]
							})
							,new GridCellHead(id+":grid:head:vehicles_ref",{
								"value":"ТС",
								"columns":[
									new GridColumnRef({
										"field":model.getField("vehicles_ref"),
										"ctrlClass":VehicleEdit,
										"searchOptions":{
											"field":new FieldInt("vehicle_id"),
											"searchType":"on_match"
										}									
									})
								]
							})
							,new GridCellHead(id+":grid:head:drivers_ref",{
								"value":"Водитель",
								"columns":[
									new GridColumn({
										"field":model.getField("drivers_ref"),
										"ctrlClass":DriverEditRef,
										"searchOptions":{
											"field":new FieldInt("driver_id"),
											"searchType":"on_match"
										},
										"formatFunction":function(fields,cell){
											return window.getApp().formatCell(fields.drivers_ref,cell,self.COL_DRIVER_LEN);
										}																		
									})
								]
							})
							,new GridCellHead(id+":grid:head:owner",{
								"value":"Владелец ТС",
								"columns":[
									new GridColumn({
										"field":model.getField("owner")
									})
								]
							})
							,new GridCellHead(id+":grid:head:load_capacity",{
								"value":"Груз.",
								"columns":[
									new GridColumn({
										"field":model.getField("load_capacity")
									})
								]
							})
							,new GridCellHead(id+":grid:head:state",{
								"value":"Сост.",
								"columns":[
									new EnumGridColumn_vehicle_states({
										"field":model.getField("state")
									})
								]
							})
							,new GridCellHead(id+":grid:head:out_comment",{
								"value":"Комментарий",
								"columns":[
									new GridColumn({
										"field":model.getField("out_comment")
									})
								]
							})
							,new GridCellHead(id+":grid:head:phone_cel",{
								"value":"Телефон",
								"columns":[
									new GridColumnPhone({
										"field":model.getField("phone_cel"),
										"telExt":window.getApp().getServVar("tel_ext")
									})
								]
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
		});	
		this.addElement(grid);
		
		per_select.setGrid(grid);
	}
	
	VehicleScheduleList_View.superclass.constructor.call(this,id,options);
}
extend(VehicleScheduleList_View,ViewAjxList);

VehicleScheduleList_View.prototype.COL_DRIVER_LEN = 8;

