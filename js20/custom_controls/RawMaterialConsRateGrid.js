/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends GridAjx
 * @requires core/extend.js
 * @requires controls/GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function RawMaterialConsRateGrid(id,options){
	options = options || {};	
	
	var contr = new RawMaterialConsRate_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	
	CommonHelper.merge(options,{
		"keyIds":["rate_date_id"],
		"controller":contr,
		"editInline":null,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdInsert":false,
			"cmdInsert":false,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":null,
			"cmdSearch":false,
			"variantStorage":options.variantStorage
		}),
		"filters":(options.detailFilters&&options.detailFilters.RawMaterialConsRateList_Model)? options.detailFilters.RawMaterialConsRateList_Model:null,
		"popUpMenu":popup_menu,
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0")
			]		
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	
	
	RawMaterialConsRateGrid.superclass.constructor.call(this,id,options);
}

extend(RawMaterialConsRateGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
RawMaterialConsRateGrid.prototype.onGetData = function(resp){
	var mat_m = resp? resp.getModel("RawMaterial_Model") : null;
	
	//CUSTOM HEADER&&Footer
	var h_row = this.getHead().getElement("row0");
	h_row.delDOM();
	h_row.clear();
	//f_row.delDOM();
	//f_row.clear();		
	h_row.addElement(new GridCellHead(h_row.getId()+":concrete_type_descr",{
		"value":"Марка бетона",
		"columns":[
			new GridColumn({
				"field":this.m_model.getField("concrete_type_descr")
			})
		]
	}));
	
	var mat_ind = 0;		
	while(mat_m.getNextRow()){
		mat_ind++;
		var col_mat_id = mat_m.getFieldValue("id");
		var col_id = "mat_"+mat_ind+"_rate";
		h_row.addElement(new GridCellHead(h_row.getId()+":"+col_id,{
			"value":mat_m.getFieldValue("name"),
			"colAttrs":{"material_id":col_mat_id,"align":"right"},
			"columns":[
				new GridColumnFloat({
					"fieldId":col_id
				})
			]
		}));		
	}
	
	this.getHead().toDOM();		
	
	RawMaterialConsRateGrid.superclass.onGetData.call(this,resp);
}

