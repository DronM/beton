/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConcreteCostForOwnerHeaderList_View(id,options){	

	ConcreteCostForOwnerHeaderList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ConcreteCostForOwnerHeader_Model;
	var contr = new ConcreteCostForOwnerHeader_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["id"],
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
						new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":500
									},
									"master":true,
									"detailViewClass":ConcreteCostForOwnerList_View,
									"detailViewOptions":{
										"detailFilters":{
											"ConcreteCostForOwnerList_Model":[
												{
												"masterFieldId":"id",
												"field":"header_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}									
								})
							]
						})						
						,new GridCellHead(id+":grid:head:create_date",{
							"value":"Дата создания",
							"columns":[
								new GridColumnDate({
									"field":model.getField("create_date"),
									"ctrlClass":EditDate,
									"ctrlOptions":{
										"value":DateHelper.time(),
										"enabled":false
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
extend(ConcreteCostForOwnerHeaderList_View,ViewAjx);
