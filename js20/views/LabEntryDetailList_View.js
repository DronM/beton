/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function LabEntryDetailList_View(id,options){	

	options = options || {};
	options.models = options.models || {};
	
	LabEntryDetailList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.detailFilters? true : (options.models.LabEntryDetailList_Model? false:true);
	var model = options.models.LabEntryDetailList_Model? options.models.LabEntryDetailList_Model : new LabEntryDetailList_Model();
	var contr = new LabEntryDetail_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var filters;
		
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["id_key"],
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":false,
			"filters":null,
			"variantStorage":options.variantStorage,
			"cmdSearch":false
		}),
		"popUpMenu":popup_menu,
		
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						/*
						new GridCellHead(id+":grid:head:code",{
							"value":"№",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("code"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"labelCaption":"",
										"enabled":false
									}
								})
							]
						})
						,*/
						new GridCellHead(id+":grid:head:ok",{
							"value":"ОК",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("ok"),
									"ctrlClass":EditString,
									"ctrlOptions":{
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:weight",{
							"value":"Масса",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("weight"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:p7",{
							"value":"p7",
							"colAttrs":{"align":"center"},
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
							"colAttrs":{"align":"center"},
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
						,new GridCellHead(id+":grid:head:p_date",{
							"value":"Дата",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumnDate({
									"field":model.getField("p_date"),
									"ctrlClass":EditDate,
									"ctrlOptions":{
										"enabled":false
									}									
								})
							]
						})
						,new GridCellHead(id+":grid:head:kn",{
							"value":"kn",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("kn"),
									"ctrlClass":EditInt,
									"ctrlOptions":{									
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:mpa",{
							"value":"МПА",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("mpa"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"enabled":false
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:mpa_avg",{
							"value":"МПА средн.",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("mpa_avg"),
									"ctrlClass":EditInt,
									"ctrlOptions":{
										"enabled":false
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:pres_norm",{
							"value":"Норма",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({
									"field":model.getField("pres_norm"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"enabled":false
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
		"filters":options.detailFilters? options.detailFilters.LabEntryDetailList_Model:null,
		"autoRefresh":auto_refresh,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	


}
extend(LabEntryDetailList_View,ViewAjxList);

