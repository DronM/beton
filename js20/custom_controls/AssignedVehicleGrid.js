/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends Grid
 * @requires core/extend.js
 * @requires controls/Grid.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function AssignedVehicleGrid(id,options){
	options = options || {};	
	
	options.className = OrderMakeList_View.prototype.TABLE_CLASS+" "+window.getApp().getBsCol(12);
	
	if(!options.refreshInterval)
		options.contClassName = window.getApp().getBsCol(5);
		
	options.keyIds = ["id"];
	options.editInline = false;
	options.editWinClass = null;
	options.commands = null;
	options.popUpMenu = null;
	options.onEventSetRowOptions = function(opts){
		var m = this.getModel();
		var ass_time = m.getFieldValue("date_time");
		if(ass_time && ((DateHelper.time().getTime()-ass_time.getTime())/1000/60)<=2 ){		
			opts.className = opts.className||"";
			opts.className+=(opts.className.length? " ":"")+"just_assigned";
		}
	};
	options.head = new GridHead(id+":head",{
		"elements":[
			new GridRow(id+":head:row0",{
				"elements":[
					new GridCellHead(id+":head:row0:header",{
						"value":options.prodSiteDescr,
						"colSpan":2
					})
				]
			})		
			,new GridRow(id+":head:row1",{
				"elements":[
					new GridCellHead(id+":head:row1:driver",{
						"value":"Водитель",
						"columns":[
							new GridColumn({
								"id":"driver",
								"formatFunction":function(f){
									var res = (f&&f.drivers_ref&&!f.drivers_ref.isNull())? f.drivers_ref.getValue().getDescr():"";
									res+= (f&&f.vehicles_ref&&!f.vehicles_ref.isNull())? ","+f.vehicles_ref.getValue().getDescr():"";
									return res;
								}
							})
						]
					})
					,new GridCellHead(id+":head:row1:destinations_ref",{
						"value":"Объект",
						"columns":[
							new GridColumnRef({
								"field":options.model.getField("destinations_ref")
							})
						]
					})
				]
			})
		]
	});
	
	
	this.m_prodSiteId = options.prodSiteId;
	
	AssignedVehicleGrid.superclass.constructor.call(this,id,options);
}

extend(AssignedVehicleGrid,Grid);

/* Constants */


/* private members */

/* protected*/


/* public methods */

AssignedVehicleGrid.prototype.onGetData = function(){
	if (this.m_model){
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
		
		while(this.m_model.getNextRow()){			
			
			//ADDED CODE
			var site_ref = this.m_model.getFieldValue("production_sites_ref");
			if(site_ref&&!site_ref.isNull()&&site_ref.getKey()!=this.m_prodSiteId){
				continue;
			}
			//ADDED CODE
			
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
			row_cnt++;

			//foot
			if (foot && foot.calc){	
				foot.calc(this.m_model);
			}		
		}
		
		if (this.getLastRowFooter() && row){
			DOMHelper.addClass(row.m_node,"grid_foot");
		}
		
		if (foot && foot.calcEnd){	
			foot.calcEnd(this.m_model);
		}
		
		body.toDOM(this.m_node);
		
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

