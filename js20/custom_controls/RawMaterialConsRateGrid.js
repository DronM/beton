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
	
	RawMaterialConsRateGrid.superclass.constructor.call(this,id,options);
}

extend(RawMaterialConsRateGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
RawMaterialConsRateGrid.prototype.initEditView = function(parent,replacedNode,cmd){

	RawMaterialConsRateGrid.superclass.initEditView.call(this,parent,replacedNode,cmd);
	
	var fields = this.m_model.getFields();
	var pm = this.m_editViewObj.getWritePublicMethod();
	for(var i=1;i<=10;i++){
		pm.setFieldValue("mat"+i+"_id",fields["mat"+i+"_id"].getValue());
	}
}

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
				"field":this.getModel().getField("concrete_type_descr"),
				"ctrlClass":EditString,
				"ctrlOptions":{
					"enabled":false,
					"cmdClear":false
				}
			})
		]
	}));
	
	if(mat_m){
		var mat_ind = 0;		
		while(mat_m.getNextRow()){
			mat_ind++;
			var col_mat_id = mat_m.getFieldValue("id");
			var col_id = "mat"+mat_ind+"_rate";
			h_row.addElement(new GridCellHead(h_row.getId()+":"+col_id,{
				"value":mat_m.getFieldValue("name"),
				"colAttrs":{"material_id":col_mat_id,"align":"right"},
				"columns":[
					new GridColumnFloat({
						"field":this.getModel().getField(col_id),
						"precision":"4",
						"ctrlClass":EditFloat,						
						"ctrlOptions":{
							"precision":4
						}
					})
				]
			}));
		}
	}		
	
	this.getHead().toDOM();	
	//debugger
	RawMaterialConsRateGrid.superclass.onGetData.call(this,resp);
}

