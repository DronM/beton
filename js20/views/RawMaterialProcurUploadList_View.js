/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function RawMaterialProcurUploadList_View(id,options){	

	RawMaterialProcurUploadList_View.superclass.constructor.call(this,id,options);

	var model = options.models.RawMaterialProcurUploadView_Model;
	var contr = new RawMaterialProcurUpload_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["date_time"],
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":null,		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/y H:s"
								})
							]
						})
						,new GridCellHead(id+":grid:head:result",{
							"value":"Результат",
							"columns":[
								new GridColumnBool({
									"field":model.getField("result")
								})
							]
						})
						,new GridCellHead(id+":grid:head:doc_count",{
							"value":"Кол-во документов",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("doc_count")
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
extend(RawMaterialProcurUploadList_View,ViewAjx);
