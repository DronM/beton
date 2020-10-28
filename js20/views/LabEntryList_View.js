/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function LabEntryList_View(id,options){	

	options = options || {};
	options.models = options.models || {};
	
	LabEntryList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.LabEntryList_Model? false:true;
	var model = options.models.LabEntryList_Model? options.models.LabEntryList_Model : new LabEntryList_Model();
	var contr = new LabEntry_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var filters;
	if(!options.detailFilters){
		filters = {
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
		,"production_site":{
			"binding":new CommandBinding({
				"control":new ProductionSiteEdit(id+":filter-ctrl-production_site",{
					"contClassName":"form-group-filter",
					"labelCaption":"Завод:"
				}),
				"field":new FieldInt("production_site_id")}),
			"sign":"e"		
		}
		,"concrete_type":{
			"binding":new CommandBinding({
				"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Марка:"
				}),
				"field":new FieldInt("concrete_type_id")}),
			"sign":"e"		
		}
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEdit(id+":filter-ctrl-client",{
					"contClassName":"form-group-filter",
					"labelCaption":"Клиент:"
				}),
				"field":new FieldInt("client_id")}),
			"sign":"e"		
		}
		,"destination":{
			"binding":new CommandBinding({
				"control":new DestinationEdit(id+":filter-ctrl-destination",{
					"contClassName":"form-group-filter",
					"labelCaption":"Объект:"
				}),
				"field":new FieldInt("destination_id")}),
			"sign":"e"		
		}
		,"ok":{
			"binding":new CommandBinding({
				"control":new EditInt(id+":filter-ctrl-ok",{
					"contClassName":"form-group-filter",
					"labelCaption":"ОК:"
				}),
				"field":new FieldInt("ok")}),
			"sign":"e"		
		}
		,"shipment_id":{
			"binding":new CommandBinding({
				"control":new ShipmentEdit(id+":filter-ctrl-shipment",{
					"contClassName":"form-group-filter",
					"labelCaption":"Отгрузка:",
					"keyIds":["shipment_id"]
				}),
				"field":new FieldInt("shipment_id")}),
			"sign":"e"		
		}
		
		};
	}
	
	var self = this;
	this.addElement(
		new EditCheckBox(id+":filter-samples_exist",{
			"labelCaption":"Только отобранные",
			"labelAlign":"right",
			"className":"col-lg-2",
			"labelClassName":"col-lg-10",
			"editContClassName":"col-lg-2",
			"events":{
				"change":function(){
					var gr = self.getElement("grid");
					var sel = this.getValue();
					if(sel){
						gr.setFilter({
							"field":"samples_exist",
							"sign":"e",
							"val":"1"
						});
					}
					else{
						gr.unsetFilter("samples_exist"+"e");
					}
					window.setGlobalWait(true);
					gr.onRefresh(function(){
						window.setGlobalWait(false);
					});
				}
			}
		})
	);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	var grid = new GridAjx(id+":grid",{
		"keyIds":["shipment_id"],
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":!options.detailFilters,
			"cmdInsert":false,
			"cmdDelete":true,
			"cmdEdit":true,
			"filters":filters,
			"variantStorage":options.variantStorage,
			"cmdSearch":!options.detailFilters
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:shipment_id",{
							"value":"№",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("shipment_id"),
									"ctrlClass":EditNum,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									},
									"searchOptions":{
										"field":new FieldInt("shipment_id"),
										"searchType":"on_match"
									},
									"master":true,
									"detailViewClass":LabEntryDetailList_View,
									"detailViewOptions":{
										"detailFilters":{
											"LabEntryDetailList_Model":[
												{
												"masterFieldId":"shipment_id",
												"field":"shipment_id",
												"sign":"e",
												"val":"0"
												}
											]
										}													
									}																		
								})
							]
						})
					
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									"ctrlClass":EditDateTime,
									"dateFormat":"d/m/y H:i",									
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							],
							"sortable":true,
							"sort":"desc"														
						})
						
						,new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							],
							"sortable":true
						})

						,new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref"),
									"ctrlClass":ConcreteTypeEdit,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							],
							"sortable":true
						})
					
						,new GridCellHead(id+":grid:head:ok",{
							"value":"ОК",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("ok"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"enabled":false
									}																		
								})
							]							
						})

						,new GridCellHead(id+":grid:head:weight",{
							"value":"Масса",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("weight"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"enabled":false
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:p7",{
							"value":"p7",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("p7"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"enabled":false
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:p28",{
							"value":"p28",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("p28"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"enabled":false
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:samples",{
							"value":"Подборы",
							"colAttrs":{"align":"left"},
							"columns":[
								new GridColumn({
									"field":model.getField("samples"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":500
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:raw_material_cons_rate_dates_ref",{
							"value":"Подборы (справочник)",
							"columns":[
								new GridColumnRef({
									"field":model.getField("raw_material_cons_rate_dates_ref"),
									"ctrlClass":RawMaterialConsRateDateEdit,
									"ctrlBindFieldId":"rate_date_id",
									"ctrlOptions":{
										"labelCaption":"",
										"onSelect":function(fields){
											self.setCodeToEditForm(fields.code.getValue());
										}
									}																		
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:ok2",{
							"value":"ОК2",
							"colAttrs":{"align":"left"},
							"columns":[
								new GridColumn({
									"field":model.getField("ok2"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":500
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:time",{
							"value":"Время",
							"colAttrs":{"align":"left"},
							"columns":[
								new GridColumn({
									"field":model.getField("time"),
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
		"filters":options.detailFilters? options.detailFilters.LabEntryList_Model:null,
		"autoRefresh":auto_refresh,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	
	

	//перекрытие чтобы не удалялась строка
	
	grid.afterServerDelRow = function(){
		this.setEnabled(true);
		window.showTempNote(this.NT_REC_DELETED,null,this.m_onDelOkMesTimeout);			
		this.focus();
		this.onRefresh();
	}
	
	this.addElement(grid);
}
extend(LabEntryList_View,ViewAjxList);


LabEntryList_View.prototype.setCodeToEditForm = function(code){
	var view = this.getElement("grid").getEditViewObj();
	if(view){
		view.getElement("samples").setValue(code);
	}
}





