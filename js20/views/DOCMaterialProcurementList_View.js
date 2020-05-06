/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function DOCMaterialProcurementList_View(id,options){	

	DOCMaterialProcurementList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.DOCMaterialProcurementList_Model)? options.models.DOCMaterialProcurementList_Model:new DOCMaterialProcurementList_Model();
	var contr = new DOCMaterialProcurement_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["id"],
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":null,
		"contClassName":options.detailFilters? window.getBsCol(11):null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdInsert":false,
			"cmdDelete":false,
			"cmdFilter":false,
			"cmdSearch":false,
			"filters":null,
			"variantStorage":null
		}),
		"filters":(options.detailFilters&&options.detailFilters.DOCMaterialProcurementList_Model)? options.detailFilters.DOCMaterialProcurementList_Model:null,
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
									"dateFormat":"d/m/y H:s"
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:number",{
							"value":"Номер",
							"columns":[
								new GridColumn({
									"field":model.getField("number")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:materials_ref",{
							"value":"Материал",
							"columns":[
								new GridColumnRef({
									"field":model.getField("materials_ref")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:cement_silos_ref",{
							"value":"Силос",
							"columns":[
								new GridColumnRef({
									"field":model.getField("cement_silos_ref")
								})
							],
							"sortable":true
						})
						
						,new GridCellHead(id+":grid:head:suppliers_ref",{
							"value":"Поставщик",
							"columns":[
								new GridColumnRef({
									"field":model.getField("suppliers_ref")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:carriers_ref",{
							"value":"Перевозчик",
							"columns":[
								new GridColumnRef({
									"field":model.getField("carriers_ref")
								})
							]
						})
						,new GridCellHead(id+":grid:head:vehicle_plate",{
							"value":"ТС",
							"columns":[
								new GridColumn({
									"field":model.getField("vehicle_plate")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:driver",{
							"value":"Водитель",
							"columns":[
								new GridColumn({
									"field":model.getField("driver")
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:quant_net",{
							"value":"Вес нетто",
							"colAttrs":{"align":"right"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant_net"),
									"precision":"4"
								})
							]
						})
						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(DOCMaterialProcurementList_View,ViewAjxList);

