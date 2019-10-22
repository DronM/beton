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
function RawMaterialConsRateList_View(id,options){
	options = options || {};	
	
	RawMaterialConsRateList_View.superclass.constructor.call(this,id,options);
	
	var contr = new RawMaterialConsRate_Controller();
	var model = (options.models&&options.models.RawMaterialConsRateList_Model)? options.models.RawMaterialConsRateList_Model:new RawMaterialConsRateList_Model();
	
	var constants = {"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	//
	this.addElement(new RawMaterialConsRateGrid(id+":grid",{
		"keyIds":["rate_date_id","concrete_type_id"],
		"model":model,
		//"updatePublicMethod":contr.getPublicMethod("update_material_rate"),
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":true,
			"cmdDelete":true,
			"cmdFilter":false,
			"filters":null,
			"cmdSearch":false,
			"variantStorage":null
		}),
		"filters":(options.detailFilters&&options.detailFilters.RawMaterialConsRateList_Model)? options.detailFilters.RawMaterialConsRateList_Model:null,
		"popUpMenu":popup_menu,
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
				})
			]		
		}),
		"pagination":null,
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));
	
}
extend(RawMaterialConsRateList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

