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
function MaterialFactConsumptionGrid(id,options){
	options = options || {};	
	
	MaterialFactConsumptionGrid.superclass.constructor.call(this,id,options);
}

extend(MaterialFactConsumptionGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
MaterialFactConsumptionGrid.prototype.onGetData = function(resp){
	var mat_m = resp? resp.getModel("MaterialFactConsumptionHeader_Model") : null;
	
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

