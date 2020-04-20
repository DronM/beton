/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function ConcreteTypeMapToProductionList_View(id,options){	
	options = options || {};
	options.models = options.models || {};
	
	ConcreteTypeMapToProductionList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.ConcreteTypeMapToProductionList_Model? false:true;
	var model = options.models.ConcreteTypeMapToProductionList_Model? options.models.ConcreteTypeMapToProductionList_Model : new ConcreteTypeMapToProductionList_Model();
	var contr = new ConcreteTypeMapToProduction_Controller();
	
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
						new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка в этой программе",
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref"),
									"ctrlClass":ConcreteTypeEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"concrete_type_id"
								})
							]
						})
						,new GridCellHead(id+":grid:head:production_descr",{
							"value":"Марка в производстве",
							"columns":[
								new GridColumn({
									"field":model.getField("production_descr")
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
extend(ConcreteTypeMapToProductionList_View,ViewAjxList);
