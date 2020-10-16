/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function GPSTrackerList_View(id,options){	

	GPSTrackerList_View.superclass.constructor.call(this,id,options);

	var model = options.models.GPSTracker_Model;
	var contr = new GPSTracker_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:id",{
							"value":"Идентификатор",
							"columns":[
								new GridColumn({
									"field":model.getField("id")
								})
							],
							"sortable":true,
							"sort":"asc"
						})
						,new GridCellHead(id+":grid:head:sim_id",{
							"value":"sim_id",
							"columns":[
								new GridColumn({
									"field":model.getField("sim_id")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:sim_number",{
							"value":"sim_number",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("sim_number")
								})
							],
							"sortable":true
						})
						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(GPSTrackerList_View,ViewAjx);
