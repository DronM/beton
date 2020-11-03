/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ProductionSiteForEditList_View(id,options){
	options = options || {};	
	
	ProductionSiteForEditList_View.superclass.constructor.call(this,id,options);
	
	
	var model = options.models.ProductionSiteForEditList_Model;
	var contr = new ProductionSite_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_list_for_edit"),
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"addCustomCommandsAfter":function(commands){
				commands.push(new ProductionSiteCmdLoadProduction(id+":grid:cmd:LoadProduction"));				
			}
		}),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":100
									}
								})
							],
							"sortable":true,
							"sort":"asc"							
						})
						,new GridCellHead(id+":grid:head:active",{
							"value":"Активен",
							"columns":[
								new GridColumnBool({
									"field":model.getField("active")
								})
							]
						})
						,new GridCellHead(id+":grid:head:last_elkon_production_id",{
							"value":"№ производства Elkon",
							"columns":[
								new GridColumn({
									"field":model.getField("last_elkon_production_id")
								})
							]
						})
						,new GridCellHead(id+":grid:head:elkon_connection",{
							"value":"Соединение с сервром Elkon",
							"columns":[
								new GridColumn({
									"field":model.getField("elkon_connection"),
									"ctrlOptions":{
										"enabled":false
									},
									"formatFunction":function(fields){
										var res = "";
										var con = fields.elkon_connection.getValue();
										if(con){
											res = "Сервер:"+con.host+
											" Порт:"+con.port+
											" база:"+con.databaseName+
											" Уровень лога:"+con.logLevel+
											" Пользователь:"+con.userName+
											" Пароль:"+con.userPassword
										}
										return res;
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:missing_elkon_production_ids",{
							"value":"Пропущенные пр-ва",
							"columns":[
								new GridColumn({
									"field":model.getField("missing_elkon_production_ids"),
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
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));	
		
}
//ViewObjectAjx,ViewAjxList
extend(ProductionSiteForEditList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

