/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function MaterialFactConsumptionList_View(id,options){	

	options = options || {};	
	options.models = options.models || {};
	
	this.HEAD_TITLE = "Фактический расход материалов";
	
	MaterialFactConsumptionList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.detailFilters? true : (options.models.MaterialFactConsumptionList_Model? false:true);
	var model = options.models.MaterialFactConsumptionList_Model? options.models.MaterialFactConsumptionList_Model : new MaterialFactConsumptionList_Model();
	var contr = new MaterialFactConsumption_Controller();
	
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
		
		};
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
			"cmdDelete":false,
			"cmdEdit":false,
			"cmdFilter":!options.detailFilters,
			"filters":filters,
			"variantStorage":options.variantStorage,
			"cmdSearch":!options.detailFilters
		}),
		"popUpMenu":popup_menu,
		"onEventSetCellOptions":function(opts){
			if(!this.m_matchCheckColList){
				this.m_matchCheckColList = ["vehicles_ref","raw_materials_ref","concrete_types_ref"];
			}
			var col = opts.gridColumn.getId();
			if(CommonHelper.inArray(col,this.m_matchCheckColList)!=-1){
				opts.className = opts.className||"";
				var m = this.getModel();
				if(m.getField(col).isNull()){
					opts.title="Соответствие не определено!";
					opts.className+=(opts.className.length? " ":"")+"production_upload_no_match";
				}
			}				
		},
		
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									"ctrlClass":EditDateTime,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							],
							"sort":"desc"																					
						})
						,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:production_sites_ref",{
							"value":"Завод",
							"columns":[
								new GridColumnRef({
									"field":model.getField("production_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									},
									"ctrlBindFieldId":"production_site_id"
								})
							]
						})
					
						/*,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:upload_users_ref",{
							"value":"Кто загрузил",
							"columns":[
								new GridColumnRef({
									"field":model.getField("upload_users_ref"),
									"ctrlClass":UserEditRef,
									"form":User_Form,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									},
									"ctrlBindFieldId":"upload_user_id"
								})
							]
						})
						
						,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:upload_date_time",{
							"value":"Дата загрузки",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("upload_date_time"),
									"ctrlClass":EditDateTime,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}									
								})
							]
						})
						*/
						,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:concrete_types_ref",{
							"value":"Марка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("concrete_types_ref"),
									"ctrlClass":ConcreteTypeEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"concrete_type_id",
									"formatFunction":function(fields){
										return fields.concrete_types_ref.isNull()? fields.concrete_type_production_descr.getValue():fields.concrete_types_ref.getValue().getDescr();
									}									
								})
							]
						})
						
						,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:vehicles_ref",{
							"value":"ТС",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicles_ref"),
									"form":VehicleDialog_Form,
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id",
									"formatFunction":function(fields){
										return fields.vehicles_ref.isNull()? fields.vehicle_production_descr.getValue():fields.vehicles_ref.getValue().getDescr();
									}									
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:raw_materials_ref",{
							"value":"Материал",
							"columns":[
								new GridColumnRef({
									"field":model.getField("raw_materials_ref"),
									"ctrlClass":MaterialSelect,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"raw_material_id",
									"formatFunction":function(fields){
										return fields.raw_materials_ref.isNull()? fields.raw_material_production_descr.getValue():fields.raw_materials_ref.getValue().getDescr();
									}									
								})
							]
						})
						
						,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:orders_ref",{
							"value":"Заявка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("orders_ref"),
									"ctrlClass":OrderEdit,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									},
									"form":OrderDialog_Form
								})
							]
						})
						
						,
						options.detailFilters? null:
						new GridCellHead(id+":grid:head:shipments_inf",{
							"value":"Отгрузка",
							"columns":[
								new GridColumn({
									"field":model.getField("shipments_inf"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							]
						})
					
					
						,options.detailFilters? null:
						new GridCellHead(id+":grid:head:concrete_quant",{
							"value":"Объем",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("concrete_quant"),
									"ctrlClass":EditFloat,
									"ctrlOptions":{
										"precision":4
									}																		
								})
							]
						})
						
						,new GridCellHead(id+":grid:head:material_quant",{
							"value":"Количество",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("material_quant"),
									"ctrlClass":EditFloat,
									"ctrlOptions":{
										"precision":4
									}																		
								})
							]
						})
						,new GridCellHead(id+":grid:head:material_quant_req",{
							"value":"Количество треб.",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumn({
									"field":model.getField("material_quant_req"),
									"ctrlClass":EditFloat,
									"ctrlOptions":{
										"precision":4
									}																		
								})
							]
						})
						
					]
				})
			]
		}),
		"pagination":options.detailFilters?
			null:(new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()})),
		"filters":options.detailFilters? options.detailFilters.MaterialFactConsumptionList_Model:null,
		"autoRefresh":auto_refresh,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	


}
extend(MaterialFactConsumptionList_View,ViewAjxList);

