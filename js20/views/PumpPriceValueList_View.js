/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function PumpPriceValueList_View(id,options){	

	PumpPriceValueList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.PumpPriceValue_Model)? options.models.PumpPriceValue_Model : new PumpPriceValue_Model();
	var contr = options.controller || new PumpPriceValue_Controller();
		
	var popup_menu = new PopUpMenu();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdSearch":false
		}),
		"filters":(options.detailFilters&&options.detailFilters.PumpPriceValue_Model)? options.detailFilters.PumpPriceValue_Model:null,
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:quant_from",{
							"value":"м3 от",
							"columns":[
								new GridColumn({
									"field":model.getField("quant_from"),
									"ctrlClass":EditFloat,
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							],
							"sort":"asc"
						})
						,new GridCellHead(id+":grid:head:quant_to",{
							"value":"м3 до",
							"columns":[
								new GridColumn({
									"field":model.getField("quant_to"),
									"ctrlClass":EditFloat,
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:price_m",{
							"value":"Цена/м3",
							"columns":[
								new GridColumn({
									"field":model.getField("price_m"),
									"ctrlClass":EditMoney,
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:price_fixed",{
							"value":"Цена/м3",
							"columns":[
								new GridColumn({
									"field":model.getField("price_fixed"),
									"ctrlClass":EditMoney,
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})						
						
					]
				})
			]
		}),
		"pagination":null,				
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":null,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(PumpPriceValueList_View,ViewAjxList);
