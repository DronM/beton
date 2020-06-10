/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends GridAjx
 * @requires core/extend.js
 * @requires GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ClientLocalListGrid(id,options){
	var model = new ClientLocalList_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:client",{
			"columns":[
				new GridColumnRef({
					"field":model.getField("client"),
					"ctrlClass":ClientEdit,
					"ctrlOptions":{
						"labelCaption":""
					}
				})				
			]
		})
	];

	options = {
		"showHead":false,
		"model":model,
		"keyIds":["id"],
		"controller":new ClientLocalList_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false,
			"cmdInsert":true,
			"cmdEdit":true,
			"cmdDelete":true,
			"cmdAllCommands":false
		}),
		"readOnly":true,
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0",{
					"elements":cells
				})
			]
		}),
		"pagination":null,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":true
	};	
	ClientLocalListGrid.superclass.constructor.call(this,id,options);
}
extend(ClientLocalListGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
