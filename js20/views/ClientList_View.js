/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ClientList_View(id,options){	

	options.addElement = function(){
		var model = options.models.ClientList_Model;
		var contr = new Client_Controller();
		
		var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);
		
		var popup_menu = new PopUpMenu();
		var pagClass = window.getApp().getPaginationClass();
		//GridAjxScroll
		this.addElement(new GridAjx(id+":grid",{
			"model":model,
			"controller":contr,
			"editInline":false,
			"editWinClass":Client_Form,		
			"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
			"popUpMenu":popup_menu,
			"head":new GridHead(id+"-grid:head",{
				"elements":[
					new GridRow(id+":grid:head:row0",{
						"elements":[
							new GridCellHead(id+":grid:head:name",{
								"value":"Наименование",
								"columns":[
									new GridColumn({
										"field":model.getField("name")
									})
								],
								"sortable":true,
								"sort":"asc"														
							})
							,new GridCellHead(id+":grid:head:phone_cel",{
								"value":"Телефон",
								"columns":[
									new GridColumnPhone({"field":model.getField("phone_cel")})
								]
							})						
							,new GridCellHead(id+":grid:head:quant",{
								"value":"Объем",
								"columns":[
									new GridColumn({"field":model.getField("quant")})
								]
							})						
							,new GridCellHead(id+":grid:head:client_types_ref",{
								"value":"Вид клиента",
								"columns":[
									new GridColumnRef({
										"field":model.getField("client_types_ref"),
										"ctrlClass":ClientTypeEdit,
										"searchOptions":{
											"field":new FieldInt("client_type_id"),
											"searchType":"on_match"
										}									
									})
								]
							})						
							,new GridCellHead(id+":grid:head:client_come_from_ref",{
								"value":"Источник обращения",
								"columns":[
									new GridColumnRef({
										"field":model.getField("client_come_from_ref"),
										"ctrlClass":ClientComeFromEdit,
										"searchOptions":{
											"field":new FieldInt("client_come_from_id"),
											"searchType":"on_match"
										}																		
									})
								]
							})						
							
							,new GridCellHead(id+":grid:head:first_call_date",{
								"value":"Первый звонок",
								"columns":[
									new GridColumnDate({"field":model.getField("first_call_date")})
								]
							})						

							,new GridCellHead(id+":grid:head:inn",{
								"value":"ИНН",
								"columns":[
									new GridColumn({
										"field":model.getField("inn")
									})
								],
								"sortable":true
							})						
							
						]
					})
				]
			}),
			"pagination":new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()}),				
			"autoRefresh":false,
			"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
			"rowSelect":false,
			"focus":true
		}));	
	}
		
	ClientList_View.superclass.constructor.call(this,id,options);
}
extend(ClientList_View,ViewAjxList);


