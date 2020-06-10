/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function RawMaterialConsRateDateList_View(id,options){	

	RawMaterialConsRateDateList_View.superclass.constructor.call(this,id,options);

	var model = options.models.RawMaterialConsRateDateList_Model;
	var contr = new RawMaterialConsRateDate_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("dt")
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
			"cmdInsert":true,
			"cmdDelete":true,
			"cmdEdit":true,
			"cmdCopy":false,
			"cmdFilter":false,
			"filters":filters,
			"variantStorage":options.variantStorage,
			"cmdAllCommands":false,
			"addCustomCommandsAfter":function(commands){
				commands.push(new RawMaterialConsRateDateGridCmd(id+":grid:cmd:calc"));
			}			
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:period",{
							"value":"Период",
							"columns":[
								new GridColumn({
									"field":model.getField("period"),
									"ctrlClass":EditDate,
									"ctrlBindFieldId":"dt",
									"master":true,
									"detailViewClass":RawMaterialConsRateList_View,
									"detailViewOptions":{
										"detailFilters":{
											"RawMaterialConsRateList_Model":[
												{
												"masterFieldId":"id",
												"field":"rate_date_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}										
									
								})
							]
						})
						,new GridCellHead(id+":grid:head:name",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
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
extend(RawMaterialConsRateDateList_View,ViewAjxList);

