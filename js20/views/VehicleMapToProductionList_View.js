/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
function VehicleMapToProductionList_View(id,options){	
	
	options = options || {};
	options.models = options.models || {};
	
	VehicleMapToProductionList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.VehicleMapToProductionList_Model? false:true;
	var model = options.models.VehicleMapToProductionList_Model? options.models.VehicleMapToProductionList_Model : new VehicleMapToProductionList_Model();
	var contr = new VehicleMapToProduction_Controller();
	
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
						,new GridCellHead(id+":grid:head:vehicles_ref",{
							"value":"ТС в этой программе",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicles_ref"),
									"form":VehicleDialog_Form,
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id"									
								})
							]
						})
						,new GridCellHead(id+":grid:head:production_descr",{
							"value":"ТС в производстве",
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
extend(VehicleMapToProductionList_View,ViewAjxList);
