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
function AstCallClientCallHistoryList_View(id,options){
	options = options || {};	
	
	AstCallClientCallHistoryList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.AstCallClientCallHistoryList_Model)? options.models.AstCallClientCallHistoryList_Model : new AstCallClientCallHistoryList_Model();
	var contr = new AstCall_Controller();
		
	var grid_columns = [
		new GridCellHead(id+":grid:head:dt",{
				"value":"Дата",
				"columns":[
					new GridColumnDate({
						"field":model.getField("dt"),
						"dateFormat":"d/m/y H:i"
					})
				],
				"sortable":true,
				"sort":"desc"
		})	
		,new GridCellHead(id+":grid:head:manager_comment",{
			"value":"Комментарий",
			"columns":[
				new GridColumn({
					"field":model.getField("manager_comment")
				})
			]
		})					
		
	];
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["unique_id"],
		"readPublicMethod":contr.getPublicMethod("client_call_hist"),
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
extend(AstCallClientCallHistoryList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

