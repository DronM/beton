/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function TrackerZoneControlList_View(id,options){	

	TrackerZoneControlList_View.superclass.constructor.call(this,id,options);

	var model = options.models.TrackerZoneControlList_Model;
	var contr = new TrackerZoneControl_Controller();
	
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
						new GridCellHead(id+":grid:head:destination",{
							"value":"Зона",
							"columns":[
								new GridColumnRef({
									"field":model.getField("destinations_ref"),
									"form":Destination_Form,
									"ctrlBindFieldId":"destination_id",
									"ctrlClass":DestinationEdit,
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
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(TrackerZoneControlList_View,ViewAjxList);
