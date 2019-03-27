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
function DOCMaterialProcurementShiftGrid(id,options){
	options = options || {};	
	
	this.m_initRawMaterial_Model = options.modelMat;
	
	var contr = new DOCMaterialProcurement_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("shift_date_time")
	});
	
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
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	
	CommonHelper.merge(options,{
		"keyIds":["shift_date_time"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_shift_list"),
		"editInline":null,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdInsert":false,
			"cmdInsert":false,
			"cmdDelete":false,
			"cmdFilter":true,
			"filters":filters,
			"cmdSearch":false,
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
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	
	
	DOCMaterialProcurementShiftGrid.superclass.constructor.call(this,id,options);
}

extend(DOCMaterialProcurementShiftGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
DOCMaterialProcurementShiftGrid.prototype.onGetData = function(resp){
	if(resp){
		this.m_model.setData(resp.getModelData(this.m_model.getId()));
	}

	if (this.m_model){
		var mat_m = resp? resp.getModel("RawMaterial_Model") : this.m_initRawMaterial_Model;
		
		//CUSTOM HEADER&&Footer
		//var f_row = this.getFoot().getElement("row0");
		var h_row = this.getHead().getElement("row0");
		h_row.delDOM();
		h_row.clear();
		//f_row.delDOM();
		//f_row.clear();		
		h_row.addElement(new GridCellHead(h_row.getId()+":shift_date_time",{
			"value":"Смена",
			"columns":[
				new GridColumnDateTime({
					"field":this.m_model.getField("shift_date_time"),
					"master":true,
					"detailViewClass":DOCMaterialProcurementList_View,
					"detailViewOptions":{
						"detailFilters":{
							"DOCMaterialProcurementList_Model":[
								{
								"masterFieldId":"shift_date_time",
								"field":"date_time",
								"sign":"ge",
								"val":"0"
								}	
								,{
								"masterFieldId":"shift_date_time_end",
								"field":"date_time",
								"sign":"le",
								"val":"0"
								}									
							]
						}													
					}										
				})
			],
			"sortable":true,
			"sort":"desc"
		}));
		//f_row.addElement(new GridCell(h_row.getId()+":sp1"));
				
		while(mat_m.getNextRow()){
			var col_mat_id = mat_m.getFieldValue("id");
			var col_id = "quant_"+col_mat_id;
			h_row.addElement(new GridCellHead(h_row.getId()+":"+col_id,{
				"value":mat_m.getFieldValue("name"),
				"colAttrs":{"material_id":col_mat_id,"align":"right"},
				"columns":[
					new GridColumnFloat({
						"id":col_id
					})
				]
			}));		
			/*
			f_row.addElement(new GridCellFoot(f_row.getId()+":"+col_id,{
				"attrs":{"align":"right"},
				"calcOper":"sum",
				"calcFieldId":"quant",
				"gridColumn":new GridColumnFloat({"id":"tot_quant_"+col_mat_id})			
			}));		
			*/
		}		
		
		//********************************************************************
		//refresh from model
		var self = this;
		var body = this.getBody();
		var foot = this.getFoot();
		body.delDOM();
		body.clear();
	
		//details
		var detail_keys = {};
		var rows = body.getNode().getElementsByTagName(this.DEF_ROW_TAG_NAME);
		for (var i = 0; i < rows.length; i++) {
			if(rows[i].getAttribute("for_keys") != null){  
				detail_keys[hex_md5(rows[i].getAttribute("for_keys"))] = {
					"for_keys":rows[i].getAttribute("for_keys"),
					"node":rows[i]
				};
			}
		}
		var details_expanded = (detail_keys&&!CommonHelper.isEmpty(detail_keys));		
		var master_cell = null;
	
		if (foot && foot.calcBegin){	
			this.m_foot.calcBegin(this.m_model);
		}
	
		if (!this.getHead())return;
		
		var columns = this.getHead().getColumns();
		//var temp_input;
		
		var row_cnt = 0, field_cnt;
		var row,row_keys;
		this.m_model.reset();
	
		var pag = this.getPagination();
		if (pag){
			pag.m_from = parseInt(this.m_model.getPageFrom());
			pag.setCountTotal(this.m_model.getTotCount());
		}
	
		/* temporaly always set to 0*/
		var h_row_ind = 0;
		var key_id_ar = this.getKeyIds();
		
		var prev_shift;
		
		while(this.m_model.getNextRow()){			
			
			var shift_date_time = this.m_model.getFieldValue("shift_date_time");
			var same_row = (prev_shift&&prev_shift.getTime()==shift_date_time.getTime());
			var quant = this.m_model.getFieldValue("quant");
			var mat_id = this.m_model.getFieldValue("material_id");
			
			if(!same_row){
				row = this.createNewRow(row_cnt,h_row_ind);
			
				row_keys = {};
			
				for(var k=0;k<key_id_ar.length;k++){
					row_keys[key_id_ar[k]] = this.m_model.getFieldValue(key_id_ar[k]);
				}
			
				field_cnt = 0;
				for (var col_id=0;col_id<columns.length;col_id++){
					columns[col_id].setGrid(this);

					if (columns[col_id].getField() && columns[col_id].getField().getPrimaryKey()){
						row_keys[columns[col_id].getField().getId()] = columns[col_id].getField().getValue();
					}
								
					var cell = this.createNewCell(columns[col_id],row);
					
					//***ADDDED***
					if(cell.getAttr("material_id")==mat_id){
						cell.setValue(quant);
					}
					//***ADDDED***
				
					if(columns[col_id].getMaster()&&details_expanded){
						master_cell = cell;
					}
				
					if (this.m_onEventAddCell){
						this.m_onEventAddCell.call(this,cell);
					}
				
					row.addElement(cell);
								
					field_cnt++;				
				}
		
				row.setAttr("keys",CommonHelper.serialize(row_keys));			
			
				if (details_expanded){
					var row_key_h = hex_md5(row.getAttr("keys"));
					if(detail_keys[row_key_h]){
						detail_keys[row_key_h].masterNode = row.getNode();
						detail_keys[row_key_h].masterCell = master_cell;
					}
				}
			
				//system cell
				var row_cmd_class = this.getRowCommandClass();
				if (row_cmd_class){
					var row_class_options = {"grid":this};
					row.addElement(new row_cmd_class(this.getId()+":"+body.getName()+":"+row.getId()+":cell-sys",row_class_options));
				}
			
				if (this.m_onEventAddRow){
					this.m_onEventAddRow.call(this,row);
				}
			
				body.addElement(row);				
				
				//foot
				if (foot && foot.calc){	
					foot.calc(this.m_model);
				}						
			}
			else{
				//SAME ROW
				for (var col_id=0;col_id<columns.length;col_id++){
					var cell = columns[col_id].getGridCell();					
					if(cell.getAttr("material_id")==mat_id){
						cell.setValue(quant);
						break;
					}
					
				}
			}
			
			row_cnt++;
			prev_shift = shift_date_time;
		}
		
		if (this.getLastRowFooter() && row){
			DOMHelper.addClass(row.m_node,"grid_foot");
		}
		
		if (foot && foot.calcEnd){	
			foot.calcEnd(this.m_model);
		}
		
		//ADDED
		this.getHead().toDOM();		
		
		body.toDOM(this.m_node);

		//ADDED
		//this.getFoot().toDOM();		
		
		//details
		if (details_expanded){
			for (var det_h in detail_keys){
				if(!detail_keys[det_h].masterNode){
					DOMHelper.delNode(detail_keys[det_h].node);
				}
				else{
					var p = detail_keys[det_h].masterNode.parentNode;
					var n_r = detail_keys[det_h].masterNode.nextSibling;
					var det_row;
					if(n_r){
						det_row = p.insertBefore(detail_keys[det_h].node,n_r);
					}
					else{
						det_row = p.appendChild(detail_keys[det_h].node);
					}
					if(detail_keys[det_h].masterCell){
						var tg = detail_keys[det_h].masterCell.getDetailToggle();
						if(tg){
							tg.setDetailRow(det_row);
							tg.setDetailVisible(true);							
						}
					}
				}
			}
		}

		
		
	}
	if (this.m_navigate || this.m_navigateClick){
		this.setSelection();
	}
}

