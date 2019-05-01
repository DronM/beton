/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function StoneQuarryValList_View(id,options){	

	StoneQuarryValList_View.superclass.constructor.call(this,id,options);

	var model = options.models.StoneQuarryValList_Model;
	var contr = new StoneQuarryVal_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("start_time")
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
		,"quarry":{
			"binding":new CommandBinding({
				"control":new QuarryEdit(id+":filter-ctrl-quarry",{
					"contClassName":"form-group-filter"
				}),
				"field":new FieldInt("quarry_id")}),
			"sign":"e"		
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
			"filters":filters,
			"variantStorage":options.variantStorage
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:day",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({
									"field":model.getField("day"),
									"ctrlClass":EditDate,
									"ctrlOptions":{
										"value":DateHelper.time()
									}
								})
							],
							"sortable":true,
							"sort":"desc"														
							
						})
						,new GridCellHead(id+":grid:head:quarry_descr",{
							"value":"Карьер",
							"columns":[
								new GridColumn({
									"field":model.getField("quarry_descr"),
									"ctrlClass":QuarryEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"quarry_id"
								})
							]
						})												
						,new GridCellHead(id+":grid:head:v_nasip",{
							"value":"Насып",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("v_nasip"),
									"ctrlClass":EditFloat
								})
							]
						})												
						,new GridCellHead(id+":grid:head:v_istin",{
							"value":"Истин",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("v_istin"),
									"ctrlClass":EditFloat
								})
							]
						})												
						,new GridCellHead(id+":grid:head:v_dust",{
							"value":"Пыль",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("v_dust"),
									"ctrlClass":EditFloat
								})
							]
						})												
						,new GridCellHead(id+":grid:head:v_void",{
							"value":"Пустотность",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("v_void"),
									"ctrlClass":EditFloat
								})
							]
						})												
						,new GridCellHead(id+":grid:head:v_humid",{
							"value":"Влажность",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("v_humid"),
									"ctrlClass":EditFloat
								})
							]
						})												
						,new GridCellHead(id+":grid:head:v_comment",{
							"value":"Коммент.",
							"columns":[
								new GridColumn({
									"field":model.getField("v_comment"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":"500"
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
extend(StoneQuarryValList_View,ViewAjx);
