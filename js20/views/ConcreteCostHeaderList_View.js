/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConcreteCostHeaderList_View(id,options){	

	ConcreteCostHeaderList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ConcreteCostHeader_Model;
	var contr = new ConcreteCostHeader_Controller();
	
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
						new GridCellHead(id+":grid:head:date",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({
									"field":model.getField("date"),
									"ctrlClass":EditDate,
									"ctrlOptions":{
										"value":DateHelper.time()
									},
									"master":true,
									"detailViewClass":ConcreteCostList_View,
									"detailViewOptions":{
										"detailFilters":{
											"ConcreteCostList_Model":[
												{
												"masterFieldId":"id",
												"field":"concrete_costs_h_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}
									
								})
							],
							"sortable":true,
							"sort":"desc"														
						})
						,new GridCellHead(id+":grid:head:clients_list",{
							"value":"Список клиентов",
							"columns":[
								new GridColumn({
									"field":model.getField("clients_list"),
									"formatFunction":function(fields){
										var res = "";
										var v = fields.clients_list.getValue();
										if(v&&v.rows&&v.rows.length){
											for(var i=0;i<v.rows.length;i++){
												if(v.rows[i].fields&&v.rows[i].fields.client){
													res+= ((res=="")? res:", ")+v.rows[i].fields.client.getDescr();
												}
											}
										}
										return res;
									},
									"ctrlClass":ClientLocalListGrid,
									"ctrlOptions":{
										"maxLength":500
									}
								})
							]
						})						
						
						,new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":500
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
extend(ConcreteCostHeaderList_View,ViewAjx);
