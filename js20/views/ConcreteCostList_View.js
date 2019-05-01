/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConcreteCostList_View(id,options){	

	options = options || {};
	ConcreteCostList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.ConcreteCostList_Model)? options.models.ConcreteCostList_Model : new ConcreteCostList_Model();
	var contr = new ConcreteCost_Controller();
	
	var popup_menu = new PopUpMenu();
	var pagination = null,refresh_int = 0;

	if(!options.detailFilters){
		var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);	
		refresh_int = constants.grid_refresh_interval.getValue()*1000;
		
		var pagClass = window.getApp().getPaginationClass();
		pagination = new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()});		
	}
	
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["id"],
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":options.detailFilters? true:false,
			"cmdEdit":options.detailFilters? true:false,
			"cmdDelete":options.detailFilters? true:false,
			"filters":null,
			"cmdSearch":options.detailFilters? false:true,
			"variantStorage":options.variantStorage
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
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
						,new GridCellHead(id+":grid:head:price",{
							"value":"Цена",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("price"),
									"ctrlClass":EditMoney,
									"ctrlOptions":{									
									}
								})
							]
						})						
					]
				})
			]
		}),
		"filters":options.detailFilters? options.detailFilters.ConcreteCostList_Model:null,
		"pagination":pagination,				
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":refresh_int,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(ConcreteCostList_View,ViewAjx);
