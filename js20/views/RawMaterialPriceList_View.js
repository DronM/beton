/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */

/* constructor */
function RawMaterialPriceList_View(id,options){
	options = options || {};
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.HEAD_TITLE = "Цена на материалы";
	
	var model = (options.models && options.models.RawMaterialPriceList_Model)? options.models.RawMaterialPriceList_Model : new RawMaterialPriceList_Model();
	var contr = new RawMaterialPrice_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	
	options.addElement = function(){
		
		var pagClass = window.getApp().getPaginationClass();
		var grid = new GridAjx(id+":grid",{
			"model":model,
			"controller":contr,
			"editInline":true,
			"editWinClass":null,
			"commands":new GridCmdContainerAjx(id+":grid:cmd",{
				"variantStorage":!options.detail? options.variantStorage : null,
				"cmdSearch":!options.detail			
			}),
			"popUpMenu":new PopUpMenu(),
			"head":new GridHead(id+":grid:head",{
				"elements":[
					new GridRow(id+":grid:head:row0",{
						"elements":[
							options.detail?null:new GridCellHead(id+":grid:head:raw_materials_ref",{
								"value":"Материал",
								"columns":[
									new GridColumnRef({
										"field":model.getField("raw_materials_ref"),
										"ctrlClass":MaterialSelect,
										"ctrlOptions":{
											"labelCaption":""
										},
										"ctrlBindFieldId":"raw_material_id"
									})
								]
							})						
							,new GridCellHead(id+":grid:head:date_time",{
								"value":"Дата",
								"columns":[
									new GridColumnDateTime({
										"field":model.getField("date_time")
									})
								]
							})
							,new GridCellHead(id+":grid:head:price",{
								"value":"Цена",
								"columns":[
									new GridColumnFloat({
										"field":model.getField("price"),
										"precision":"2"
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
			"refreshInterval":!options.detail? (constants.grid_refresh_interval.getValue()*1000) : 0,
			"rowSelect":false,
			"focus":true
		});	
		this.addElement(grid);
		
	}
		
	RawMaterialPriceList_View.superclass.constructor.call(this,id,options);
}
extend(RawMaterialPriceList_View,ViewAjxList);
