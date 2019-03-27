/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function PumpPriceList_View(id,options){	

	PumpPriceList_View.superclass.constructor.call(this,id,options);

	var model = options.models.PumpPrice_Model;
	var contr = new PumpPrice_Controller();
	
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
						new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"master":true,
									"detailViewClass":PumpPriceValueList_View,
									"detailViewOptions":{
										"detailFilters":{
											"PumpPriceValue_Model":[
												{
												"masterFieldId":"id",
												"field":"pump_price_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}
								})
							],
							"sortable":true,
							"sort":"asc"
							
						})
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":null,//constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(PumpPriceList_View,ViewAjxList);
