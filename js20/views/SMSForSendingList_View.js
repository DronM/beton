/** Copyright (c) 2012,2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SMSForSendingList_View(id,options){	

	SMSForSendingList_View.superclass.constructor.call(this,id,options);

	var model = options.models.SMSForSending_Model;
	var contr = new SMSForSending_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
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
		
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdDelete":false,
			"cmdEdit":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage			
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/y H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:sms_type",{
							"value":"Тип",
							"columns":[
								new EnumGridColumn_sms_types({
									"field":model.getField("sms_type")
								})
							]
						})
						,new GridCellHead(id+":grid:head:tel",{
							"value":"Телефон",
							"columns":[
								new GridColumnPhone({
									"field":model.getField("tel")
								})
							]
						})
						,new GridCellHead(id+":grid:head:body",{
							"value":"Текст",
							"columns":[
								new GridColumn({
									"field":model.getField("body")
								})
							]
						})
						,new GridCellHead(id+":grid:head:delivered_date_time",{
							"value":"Доставка",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("delivered_date_time"),
									"dateFormat":"d/m/y H:i"
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
extend(SMSForSendingList_View,ViewAjx);
