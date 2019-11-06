/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends GridAjx
 * @requires core/extend.js
 * @requires GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function OwnerListGrid(id,options){
	var model = new OwnerList_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:dt_from",{
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("dt_from")
				})
				,new GridColumnRef({
					"field":model.getField("owner"),
					"ctrlClass":VehicleOwnerEdit,
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
		"controller":new OwnerList_Controller({"clientModel":model}),
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
	OwnerListGrid.superclass.constructor.call(this,id,options);
}
extend(OwnerListGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
