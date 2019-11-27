/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function CementSiloProductionList_View(id,options){
	options = options || {};	

	CementSiloProductionList_View.superclass.constructor.call(this,id,options);

	var model = options.models.CementSiloProductionList_Model;
	var contr = new CementSiloProduction_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var role = window.getApp().getServVar("role_id");
	var is_admin = (role="owner");
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":(is_admin),
			"cmdEdit":(is_admin),
			"cmdDelete":(is_admin),
			"cmdCopy":(is_admin)
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:cement_silos_ref",{
							"value":"Силос",
							"columns":[
								new GridColumnRef({
									"field":model.getField("cement_silos_ref"),
									"ctrlClass":CementSiloEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"cement_silo_id"
								})
							]
							//"sortable":true,
							//"sort":"asc"														
						})
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({"field":model.getField("date_time")})
							]
						})						
						,new GridCellHead(id+":grid:head:production_date_time",{
							"value":"Дата elkon",
							"columns":[
								new GridColumnDateTime({"field":model.getField("production_date_time")})
							]
						})						
						
						,new GridCellHead(id+":grid:head:production_vehicle_descr",{
							"value":"ТС elkon",
							"columns":[
								new GridColumn({"field":model.getField("production_vehicle_descr")})
							]
						})						
						,new GridCellHead(id+":grid:head:vehicles_ref",{
							"value":"ТС",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicles_ref"),
									"ctrlClass":VehicleEdit,
									"ctrlOptions":{
										"labelCaption":""
									},
									"ctrlBindFieldId":"vehicle_id"
								})
							]
						})
						,new GridCellHead(id+":grid:head:vehicle_state",{
							"value":"Статус",
							"columns":[
								new EnumGridColumn_vehicle_states({
									"field":model.getField("vehicle_state")
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
//ViewObjectAjx,ViewAjxList
extend(CementSiloProductionList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

