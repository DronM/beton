/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleList_View(id,options){	

	VehicleList_View.superclass.constructor.call(this,id,options);

	var model = options.models.Vehicle_Model;
	var contr = new Vehicle_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":VehicleDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:plate",{
							"value":"Рег.номер",
							"columns":[
								new GridColumn({
									"field":model.getField("plate")
								})
							],
							"sortable":true,
							"sort":"asc"														
						})
						,new GridCellHead(id+":grid:head:make",{
							"value":"Марка",
							"columns":[
								new GridColumn({"field":model.getField("make")})
							],
							"sortable":true
						})						
						,new GridCellHead(id+":grid:head:load_capacity",{
							"value":"Грузоподъемность",
							"columns":[
								new GridColumn({"field":model.getField("load_capacity")})
							],
							"sortable":true
						})						
						,new GridCellHead(id+":grid:head:vehicle_owner",{
							"value":"Владелец",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicle_owners_ref")
								})
							],
							"sortable":true
						})						
						,new GridCellHead(id+":grid:head:feature",{
							"value":"Свойство",
							"columns":[
								new GridColumn({"field":model.getField("feature")})
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
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(VehicleList_View,ViewAjxList);
