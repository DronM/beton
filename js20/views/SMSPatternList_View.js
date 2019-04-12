/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SMSPatternList_View(id,options){	

	SMSPatternList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.SMSPatternList_Model;
	var contr = new SMSPattern_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null,"def_lang":null};
	window.getApp().getConstantManager().get(constants);
	
	var role_id = window.getApp().getServVar("role_id");
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":SMSPatternDialog_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":(role_id=="owner"),
			"cmdEdit":(role_id=="owner" || role_id=="boss"|| role_id=="manager"),
			"cmdCopy":(role_id=="owner"),
			"cmdDelete":(role_id=="owner"),
			"cmdFilter":true
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:sms_type",{
							"value":"Тип",
							"columns":[
								new EnumGridColumn_sms_types({
									"field":model.getField("sms_type"),
									"ctrlClass":Enum_sms_types,
									"ctrlOptions":{
										"required":true
									}
								})
							]
						}),
						new GridCellHead(id+":grid:head:lang",{
							"value":"Язык",
							"columns":[
								new GridColumnRef({
									"field":model.getField("langs_ref")
								})
							]
						}),											
						new GridCellHead(id+":grid:head:pattern",{
							"value":"Текст",
							"columns":[
								new GridColumn({
									"field":model.getField("pattern")
								})
							]
						})
						,new GridCellHead(id+":grid:head:user_list",{
							"value":"Телефоны",
							"columns":[
								new GridColumn({
									"field":model.getField("user_list")
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
extend(SMSPatternList_View,ViewAjxList);
