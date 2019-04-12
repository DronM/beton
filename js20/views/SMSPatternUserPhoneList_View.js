/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SMSPatternUserPhoneList_View(id,options){	

	options = options || {};

	SMSPatternUserPhoneList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.SMSPatternUserPhoneList_Model)? options.models.SMSPatternUserPhoneList_Model:new SMSPatternUserPhoneList_Model();
	var contr = new SMSPatternUserPhone_Controller();
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdSearch":false
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь",
							"columns":[
								new GridColumn({
									"field":model.getField("users_ref"),
									"formatFunction":function(f){
										var res = "";
										var u = f.users_ref.getValue();
										if(u&&!u.isNull()){
											res = u.getDescr();
											var tel = f.user_tel.getValue();
											if(tel&&tel.length){
												res+=" ("+tel+")";
											}
										}
										return res;
									},
									"ctrlClass":UserEditRef,
									"ctrlBindFieldId":"user_id",
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
		"pagination":null,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(SMSPatternUserPhoneList_View,ViewAjxList);
