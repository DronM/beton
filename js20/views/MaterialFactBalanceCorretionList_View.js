/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function MaterialFactBalanceCorretionList_View(id,options){	

	MaterialFactBalanceCorretionList_View.superclass.constructor.call(this,id,options);

	var model = options.models.MaterialFactBalanceCorretionList_Model;
	var contr = new MaterialFactBalanceCorretion_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
	};
	var role_id = window.getApp().getServVar("role_id");	
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":filters,
			"variantStorage":options.variantStorage
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/y H:i",									
									"searchOptions":{
										"field":new FieldDate("date_time"),
										"searchType":"on_beg",
										"ctrlClass":EditDate
									}
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:balance_date_time",{
							"value":"Дата остатка",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("balance_date_time"),
									"dateFormat":"d/m/y H:i",									
									"searchOptions":{
										"field":new FieldDate("balance_date_time"),
										"searchType":"on_beg",
										"ctrlClass":EditDate
									}
								})
							],
							"sortable":true
						})
					
						,new GridCellHead(id+":grid:head:materials_ref",{
							"value":"Материал",
							"columns":[
								new GridColumnRef({
									"field":model.getField("materials_ref"),
									"ctrlClass":MaterialSelect,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"material_id",
									"searchOptions":{
										"field":new FieldInt("material_id"),
										"searchType":"on_match"
									}									
								})
							],
							"sortable":true
						})					
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"form":User_Form,
									"ctrlClass":UserEditRef,
									"ctrlBindFieldId":"user_id",
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":(role_id=="admin"||role_id=="owner"),
									},
									"searchOptions":{
										"field":new FieldInt("user_id"),
										"searchType":"on_match"
									}									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:required_balance_quant",{
							"value":"Желаемое количество",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("required_balance_quant")									
								})
							]
						})
						,new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text")
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
extend(MaterialFactBalanceCorretionList_View,ViewAjx);


