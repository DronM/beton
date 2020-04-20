/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ELKONLogList_View(id,options){	

	ELKONLogList_View.superclass.constructor.call(this,id,options);

	var model = options.models.ELKONLogList_Model;
	var contr = new ELKONLog_Controller();
	
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
		},
		"production_site":{
			"binding":new CommandBinding({
				"control":new ProductionSiteEdit(id+":filter-ctrl-production_site",{
					"contClassName":"form-group-filter",
					"labelCaption":"Завод"
				}),
				"field":new FieldInt("production_site_id")}),
			"sign":"e"		
		}
	}	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":filters
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time")
								})
							],
							"sortable":true,
							"sort":"desc"							
							
						})
						,new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({"field":model.getField("production_sites_ref")
								})
							]
						})						
						,new GridCellHead(id+":grid:head:message",{
							"value":"Сообщение",
							"columns":[
								new GridColumn({"field":model.getField("message")
								})
							]
						})						
						,new GridCellHead(id+":grid:head:level",{
							"value":"Уровень",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({"field":model.getField("level")
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
extend(ELKONLogList_View,ViewAjx);
