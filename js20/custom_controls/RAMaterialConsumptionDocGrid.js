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
function RAMaterialConsumptionDocGrid(id,options){
	options = options || {};	
	
	this.m_initRawMaterial_Model = options.modelMat;
	
	var contr = new RAMaterialConsumption_Controller();
	
	var constants = {"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("shift")
	});
	/*
	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
	};
	*/
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	
	CommonHelper.merge(options,{
		"keyIds":["date_time"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_docs_list"),
		"editInline":null,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdInsert":false,
			"cmdInsert":false,
			"cmdDelete":false,
			"cmdFilter":false,
			//"filters":filters,
			"cmdSearch":true,
			"variantStorage":options.variantStorage
		}),
		"popUpMenu":popup_menu,
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0")
			]		
		}),
		/*"foot":new GridFoot(id+"grid:foot",{
			"autoCalc":true,			
			"elements":[
				new GridRow(id+":foot:row0")		
			]
		}),*/
		"pagination":null,
		"autoRefresh":true,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true,
		"lastRowFooter":true
	});	
	
	RAMaterialConsumptionDocGrid.superclass.constructor.call(this,id,options);
}

extend(RAMaterialConsumptionDocGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
/* public methods */
RAMaterialConsumptionDocGrid.prototype.onGetData = function(resp){
	if(resp){
		this.m_model.setData(resp.getModelData(this.m_model.getId()));
	}

	if (this.m_model){
	
		var model_fields;
		if(!this.m_model.getRowCount()){
			//define header
			this.m_model.setFields({
				"date_time":new FieldDateTime("date_time")
				,"vehicle_descr":new FieldString("vehicle_descr")
				,"driver_descr":new FieldString("driver_descr")
				,"concrete_type_descr":new FieldString("concrete_type_descr")
				,"concrete_quant":new FieldString("concrete_quant")
			});
		}
	
		var mat_m = resp? resp.getModel("RawMaterial_Model") : this.m_initRawMaterial_Model;
		
		//CUSTOM HEADER&&Footer
		//var f_row = this.getFoot().getElement("row0");
		var h_row = this.getHead().getElement("row0");
		h_row.delDOM();
		h_row.clear();
		//f_row.delDOM();
		//f_row.clear();		
		h_row.addElement(new GridCellHead(h_row.getId()+":date_time",{
			"value":"Смена",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumnDate({
					"field":this.m_model.getField("date_time"),
					"dateFormat":"H:i"
				})
			]
		}));
		//f_row.addElement(new GridCell(h_row.getId()+":sp1"));

		//concrete_type
		h_row.addElement(new GridCellHead(h_row.getId()+":concrete_type_descr",{
			"value":"Марка",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumn({
					"field":this.m_model.getField("concrete_type_descr")
				})
			]
		}));		
		//vehicle
		h_row.addElement(new GridCellHead(h_row.getId()+":vehicle_descr",{
			"value":"ТС",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumn({
					"field":this.m_model.getField("vehicle_descr")
				})
			]
		}));		
		//driver
		h_row.addElement(new GridCellHead(h_row.getId()+":driver_descr",{
			"value":"Водитель",
			"columns":[
				new GridColumn({
					"field":this.m_model.getField("driver_descr")
				})
			]
		}));		
		
		//concrete quant
		h_row.addElement(new GridCellHead(h_row.getId()+":concrete_quant",{
			"value":"Объем",
			"colAttrs":{"align":"right"},
			"columns":[
				new GridColumnFloat({
					"field":this.m_model.getField("concrete_quant"),
					"precision":2
				})
			]
		}));		
		/*f_row.addElement(new GridCellFoot(f_row.getId()+":tot_concrete_quant",{
			"attrs":{"align":"right"},
			"calcOper":"sum",
			"calcFieldId":"concrete_quant",
			"gridColumn":new GridColumnFloat({"id":"tot_concrete_quant"})			
		}));*/
		
		var mat_ind = 0;		
		while(mat_m.getNextRow()){
			mat_ind++;
			var col_mat_id = mat_m.getFieldValue("id");
			var col_id = "mat"+mat_ind+"_quant";
			
			if(!this.m_model.fieldExists(col_id)){
				this.m_model.addField(new FieldFloat(col_id));
			}
			
			h_row.addElement(new GridCellHead(h_row.getId()+":"+col_id,{
				"value":mat_m.getFieldValue("name"),
				"colAttrs":{"material_id":col_mat_id,"align":"right"},
				"columns":[
					new GridColumnFloat({
						"field":this.m_model.getField(col_id),
						"precision":3
					})
				]
			}));		
			/*f_row.addElement(new GridCellFoot(f_row.getId()+":tot_quant_"+col_mat_id,{
				"attrs":{"align":"right"},
				"calcOper":"sum",
				"calcFieldId":col_id,
				"gridColumn":new GridColumnFloat({
					"id":"tot_quant_"+col_mat_id,
					"precision":3,
					"thousandSeparator":""
				})
			}));
			*/
		}		
		this.getHead().toDOM();
		//this.getFoot().toDOM();				
		
	}
	
	RAMaterialConsumptionDocGrid.superclass.onGetData.call(this,resp);
}

