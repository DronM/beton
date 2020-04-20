/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */

/* constructor */
function RawMaterialList_View(id,options){
	options = options || {};
	
	var model = options.models.RawMaterial_Model;
	var contr = new RawMaterial_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	
	options.addElement = function(){
		
		var pagClass = window.getApp().getPaginationClass();
		var grid = new GridAjx(id+":grid",{
			"model":model,
			"controller":contr,
			"editInline":true,
			"editWinClass":null,
			"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			}),
			"popUpMenu":new PopUpMenu(),
			"head":new GridHead(id+":grid:head",{
				"elements":[
					new GridRow(id+":grid:head:row0",{
						"elements":[
							new GridCellHead(id+":grid:head:ord",{
								"value":"Код",
								"columns":[
									new GridColumn({
										"field":model.getField("ord"),
										"ctrlClass":EditInt,
										"master":true,
										"detailViewClass":RawMaterialProcurRateList_View,
										"detailViewOptions":{
											"detailFilters":{
												"RawMaterialProcurRateList_Model":[
													{
													"masterFieldId":"id",
													"field":"material_id",
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
								"value":"Наименование",
								"columns":[
									new GridColumn({
										"field":model.getField("name"),
										"ctrlOptions":{
											"maxLength":100
										}
									})
								]
							})
							,new GridCellHead(id+":grid:head:supply_days_count",{
								"value":"Дней завоза",
								"columns":[
									new GridColumn({
										"field":model.getField("supply_days_count"),
										"ctrlClass":EditInt
									})
								]
							})
							,new GridCellHead(id+":grid:head:concrete_part",{
								"value":"Для бетона",
								"columns":[
									new GridColumnBool({
										"field":model.getField("concrete_part"),
										"ctrlClass":EditCheckBox
									})
								]
							})
							,new GridCellHead(id+":grid:head:supply_volume",{
								"value":"V ТС завоза",
								"columns":[
									new GridColumn({
										"field":model.getField("supply_volume"),
										"ctrlClass":EditFloat
									})
								]
							})
							,new GridCellHead(id+":grid:head:store_days",{
								"value":"Запас дней",
								"columns":[
									new GridColumn({
										"field":model.getField("store_days"),
										"ctrlClass":EditInt
									})
								]
							})
							,new GridCellHead(id+":grid:head:min_end_quant",{
								"value":"Мин.ост,тонн",
								"columns":[
									new GridColumn({
										"field":model.getField("min_end_quant"),
										"ctrlClass":EditFloat
									})
								]
							})
							,new GridCellHead(id+":grid:head:max_fact_quant_tolerance_percent",{
								"value":"% отклонения от подборов",
								"columns":[
									new GridColumnFloat({
										"field":model.getField("max_fact_quant_tolerance_percent"),
										"ctrlClass":EditFloat,
										"ctrlOptions":{
											"precision":"2"
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
		});	
		this.addElement(grid);
		
	}
		
	RawMaterialList_View.superclass.constructor.call(this,id,options);
}
extend(RawMaterialList_View,ViewAjxList);
