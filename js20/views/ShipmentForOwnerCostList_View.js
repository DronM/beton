/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentForOwnerCostList_View(id,options){	

	options = options || {};
	ShipmentForOwnerCostList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.ShipmentForOwnerCost_Model)? options.models.ShipmentForOwnerCost_Model : new ShipmentForOwnerCost_Model();
	var contr = new ShipmentForOwnerCost_Controller();
	
	var popup_menu = new PopUpMenu();
	var pagination = null,refresh_int = 0;

	if(!options.detailFilters){
		var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);	
		refresh_int = constants.grid_refresh_interval.getValue()*1000;
		
		var pagClass = window.getApp().getPaginationClass();
		pagination = new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()});		
	}
	
	var self = this;
	
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
		"onEventGetData":function(){
			this.m_distanceTo = 0;
		},
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:distance_to",{
							"value":"Расстояние, км",
							"columns":[
								new GridColumn({
									"field":model.getField("distance_to"),
									"formatFunction":function(f){
										var gr = self.getElement("grid");
										var d = f.distance_to.getValue();
										var res = (gr.m_distanceTo+"км - "+d+"км");
										gr.m_distanceTo = d + 1;
										return res;
									},									
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:price",{
							"value":"Цена, руб",
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
		"filters":options.detailFilters? options.detailFilters.ShipmentForOwnerCost_Model:null,
		"pagination":pagination,				
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":refresh_int,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(ShipmentForOwnerCostList_View,ViewAjx);
