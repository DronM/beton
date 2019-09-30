/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function RawMaterialMapToProductionList_View(id,options){	

	options = options || {};
	options.models = options.models || {};
	
	RawMaterialMapToProductionList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.RawMaterialMapToProductionList_Model? false:true;
	var model = options.models.RawMaterialMapToProductionList_Model? options.models.RawMaterialMapToProductionList_Model : new RawMaterialMapToProductionList_Model();
	var contr = new RawMaterialMapToProduction_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						,new GridCellHead(id+":grid:head:raw_materials_ref",{
							"value":"Материал в этой программе",
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
									//"dateFormat":"d/m/y H:i",
									//"editMask":"99/99/9999 99:99"
								})
							]
						})
					
						,new GridCellHead(id+":grid:head:production_descr",{
							"value":"Материал в производстве",
							"columns":[
								new GridColumn({
									"field":model.getField("production_descr"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":100
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:order_id",{
							"value":"Порядок сортировки",
							"title":"При 0 - не отображать материал в общей таблице",
							"columns":[
								new GridColumn({
									"field":model.getField("order_id"),
									"ctrlClass":EditInt
								})
							]
						})
						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":auto_refresh,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	


}
extend(RawMaterialMapToProductionList_View,ViewAjxList);
