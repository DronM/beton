/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function MaterialFactConsumptionCorretionList_View(id,options){	

	MaterialFactConsumptionCorretionList_View.superclass.constructor.call(this,id,options);

	var model = options.models.MaterialFactConsumptionCorretionList_Model;
	var contr = new MaterialFactConsumptionCorretion_Controller();
	
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
						new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"production_site_id",
									"searchOptions":{
										"field":new FieldInt("production_site_id"),
										"searchType":"on_match",
										"typeChange":false
									}
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									//"dateFormat":"d/m/y H:i",
									/*"ctrlOptions":{
										"enabled":false
									},*/
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
						/*
						,new GridCellHead(id+":grid:head:date_time_set",{
							"value":"Дата установки",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time_set"),
									"dateFormat":"d/m/y H:i",									
									"searchOptions":{
										"field":new FieldDate("date_time_set"),
										"searchType":"on_beg",
										"ctrlClass":EditDate
									}
								})
							],
							"sortable":true
						})
						*/
						,new GridCellHead(id+":grid:head:users_ref",{
							"value":"Пользователь",
							"columns":[
								new GridColumnRef({
									"field":model.getField("users_ref"),
									"ctrlClass":UserEditRef,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"user_id",
									"searchOptions":{
										"field":new FieldInt("user_id"),
										"searchType":"on_match"
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
						,new GridCellHead(id+":grid:head:cement_silos_ref",{
							"value":"Силос",
							"columns":[
								new GridColumnRef({
									"field":model.getField("cement_silos_ref"),
									"ctrlClass":CementSiloEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"cement_silo_id",
									"searchOptions":{
										"field":new FieldInt("cement_silo_id"),
										"searchType":"on_match"
									}									
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:production_id",{
							"value":"Номер производства",
							"attrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("production_id"),
									"ctrlClass":EditInt
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:elkon_id",{
							"value":"Номер записи Elkon",
							"attrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("elkon_id"),
									"ctrlClass":EditInt
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:quant",{
							"value":"Количество",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant"),
									"precision":"4"
									
								})
							]
						})
						
					]
				})
			]
		}),
		"foot":new GridFoot(id+"grid:foot",{
			"autoCalc":true,			
			"elements":[
				new GridRow(id+":grid:foot:row0",{
					"elements":[
						new GridCell(id+":grid:foot:total_sp1",{
							"colSpan":"7"
						})											
						,new GridCellFoot(id+":grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"totalFieldId":"total_quant",
							"gridColumn":new GridColumnFloat({
								"id":"tot_quant",
								"length":19,
								"precision":4
							})
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
extend(MaterialFactConsumptionCorretionList_View,ViewAjx);


