/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function AstCallClientShipHistoryList_View(id,options){
	options = options || {};	
	
	AstCallClientShipHistoryList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.AstCallClientShipHistoryList_Model)? options.models.AstCallClientShipHistoryList_Model : new AstCallClientShipHistoryList_Model();
	var contr = new AstCall_Controller();

	var grid_columns = [
		new GridCellHead(id+":grid:head:order",{
				"value":"Заявка",
				"columns":[
					new GridColumnRef({
						"field":model.getField("orders_ref"),
						"form":OrderDialog_Form
					})
				]
		})
		,new GridCellHead(id+":grid:head:concrete_type",{
				"value":"Марка",
				"columns":[
					new GridColumnRef({
						"field":model.getField("concrete_types_ref")
					})
				]
		})
		,new GridCellHead(id+":grid:head:destination",{
				"value":"Объект",
				"columns":[
					new GridColumnRef({
						"field":model.getField("destinations_ref"),
						"form":Destination_Form
					})
				]
		})		
		,new GridCellHead(id+":grid:head:quant",{
			"value":"Количество",
			"colAttrs":{"align":"right"},
			"columns":[
				new GridColumnFloat({
					"field":model.getField("quant")
				})
			]
		})
	];
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["unique_id"],
		"readPublicMethod":contr.getPublicMethod("client_ship_hist"),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":null,
		"commands":null,
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":grid_columns
				})
			]
		}),
		"pagination":null,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(AstCallClientShipHistoryList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

