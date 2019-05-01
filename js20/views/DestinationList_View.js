/** Copyright (c) 2016,2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function DestinationList_View(id,options){	

	DestinationList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DestinationList_Model;
	var contr = new Destination_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":Destination_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true,
							"sort":"asc"							
						}),
						new GridCellHead(id+":grid:head:distance",{
							"value":"Расстояние",
							"columns":[
								new GridColumn({"field":model.getField("distance")})
							]
						}),											
						new GridCellHead(id+":grid:head:time_route",{
							"value":"Время в пути",
							"columns":[
								new GridColumnTime({
									"field":model.getField("time_route"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:price",{
							"value":"Стоимость доставки",
							"columns":[
								new GridColumnFloat({"field":model.getField("price")})
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
extend(DestinationList_View,ViewAjxList);
