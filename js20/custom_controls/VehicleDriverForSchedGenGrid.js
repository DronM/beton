/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends GridAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function VehicleDriverForSchedGenGrid(id,options){
	var model = new VehicleDriverForSchedGen_Model({
		"sequences":{"id":0}
	});
	var self = this;
	var cells = [
		new GridCellHead(id+":head:vehicle",{
			"value":"Автомобиль",
			"columns":[
				new GridColumnRef({
					"field":model.getField("vehicle"),
					"ctrlClass":VehicleEdit,
					"ctrlOptions":{
						"labelCaption":"",
						"onSelect":function(f){
							self.getEditViewObj().getElement("driver").setValue(f.drivers_ref.getValue());
						}
					}					
				})
			]
		})
		,new GridCellHead(id+":head:driver",{
			"value":"Водитель",
			"columns":[
				new GridColumnRef({
					"field":model.getField("driver"),
					"ctrlClass":DriverEditRef,
					"ctrlOptions":{
						"labelCaption":""
					}					
				})
			]
		})
		
	];

	options = {
		"model":model,
		"keyIds":["id"],
		"controller":new VehicleDriverForSchedGen_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false,
			"cmdPrint":false,
			"cmdRefresh":false
		}),
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
	VehicleDriverForSchedGenGrid.superclass.constructor.call(this,id,options);
}
extend(VehicleDriverForSchedGenGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
