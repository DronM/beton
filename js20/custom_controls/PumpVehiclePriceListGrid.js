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
function PumpVehiclePriceListGrid(id,options){
	var model = new PumpVehiclePriceList_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:dt_from",{
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("dt_from")
				})
				,new GridColumnRef({
					"field":model.getField("pump_price"),
					"ctrlClass":PumpPriceEdit,
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
		"controller":new PumpVehiclePriceList_Controller({"clientModel":model}),
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
	PumpVehiclePriceListGrid.superclass.constructor.call(this,id,options);
}
extend(PumpVehiclePriceListGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
