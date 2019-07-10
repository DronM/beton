/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function LoginList_View(id,options){	

	LoginList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.LoginList_Model;
	var contr = new Login_Controller();
	
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
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"form":User_Form
								})
							],
							"sortable":true
						})
					
						,new GridCellHead(id+":grid:head:date_time_in",{
							"value":"Дата входа",
							"columns":[
								new GridColumnDate({
									"field":model.getField("date_time_in"),
									"dateFormat":"d/m/y H:i"
								})
							],
							"sortable":true,
							"sort":"asc"							
						})
						,new GridCellHead(id+":grid:head:date_time_out",{
							"value":"Дата выхода",
							"columns":[
								new GridColumnDate({
									"field":model.getField("date_time_out"),
									"dateFormat":"d/m/y H:i"
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:set_date_time",{
							"value":"Последняя активность",
							"columns":[
								new GridColumnDate({
									"field":model.getField("set_date_time"),
									"dateFormat":"d/m/y H:i"
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:ip",{
							"value":"IP",
							"columns":[
								new GridColumn({
									"field":model.getField("ip")
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
extend(LoginList_View,ViewAjxList);
