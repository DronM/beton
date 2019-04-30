/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ClientValidDuplicateList_View(id,options){	

	ClientValidDuplicateList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ClientValidDuplicateList_Model;
	var contr = new ClientValidDuplicate_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["tel"],
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
						new GridCellHead(id+":grid:head:tel",{
							"value":"Телефон",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("tel")
								})
							],
							"sortable":true,
							"sort":"asc"
						})					
						,new GridCellHead(id+":grid:head:clients",{
							"value":"Клиенты",
							"columns":[
								new GridColumn({
									"field":model.getField("clients")
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
extend(ClientValidDuplicateList_View,ViewAjx);
