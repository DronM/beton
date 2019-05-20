/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentCancelationList_View(id,options){	

	ShipmentCancelationList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ShipmentCancelationList_Model;
	var contr = new ShipmentCancelation_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":null,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
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
							]
						})
						,new GridCellHead(id+":grid:head:orders_ref",{
							"value":"Заявка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("orders_ref"),
									"ctrlClass":OrderEdit,
									"searchOptions":{
										"field":new FieldInt("order_id"),
										"searchType":"on_match"
									}
									
								})
							]
						})
						,new GridCellHead(id+":grid:head:ship_date_time",{
							"value":"Дата отгрузки",
							"columns":[
								new GridColumnDate({
									"field":model.getField("ship_date_time"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg"
									}
									
								})
							]
						})
						,new GridCellHead(id+":grid:head:assign_date_time",{
							"value":"Дата назначения",
							"columns":[
								new GridColumnDate({
									"field":model.getField("assign_date_time"),
									"dateFormat":"d/m/y H:i",
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg"
									}
									
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:vehicle_schedules_ref",{
							"value":"ТС",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicle_schedules_ref"),
									"ctrlClass":VehicleScheduleEdit,
									"searchOptions":{
										"field":new FieldInt("vehicle_schedule_id"),
										"searchType":"on_match"
									}
									
								})
							]
						})
						,new GridCellHead(id+":grid:head:quant",{
							"value":"Кол-во",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text")
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"ctrlClass":OrderEdit,
									"searchOptions":{
										"field":new FieldInt("user_id"),
										"searchType":"on_match"
									}
									
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
	}));	
	
}
extend(ShipmentCancelationList_View,ViewAjx);
