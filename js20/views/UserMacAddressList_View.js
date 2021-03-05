/** Copyright (c) 2018
	Andrey Mikhalevich, Katren ltd.
*/
function UserMacAddressList_View(id,options){	

	options = options || {};

	UserMacAddressList_View.superclass.constructor.call(this,id,options);

	var en = (options.models && options.models.UserMacAddressList_Model);
	var mac_model = (en)? options.models.UserMacAddressList_Model:new UserMacAddressList_Model();	
	var mac_contr = new UserMacAddress_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["id"],
		"model":mac_model,
		"controller":mac_contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:mac_address",{
							"value":"MAC адрес",
							"columns":[
								new GridColumn({
									"field":mac_model.getField("mac_address"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":"17",
										"placeholder":"A0-B1-C2-D4-E5-F6",
										"regExpression":/^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/,
										"formatterOptions":{
											"delimiter": "-",
											"blocks": [2, 2, 2, 2, 2, 2],
											"uppercase": true										
										}
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
extend(UserMacAddressList_View,ViewAjx);
