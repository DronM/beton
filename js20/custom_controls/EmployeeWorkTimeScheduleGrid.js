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
function EmployeeWorkTimeScheduleGrid(id,options){
	options = options || {};	
	
	var contr = new EmployeeWorkTimeSchedule_Controller();
	
	CommonHelper.merge(options,{
		"keyIds":["day","employee_id"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_list"),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdInsert":false,
			"cmdEdit":true,
			"cmdDelete":false,
			"cmdFilter":false,
			"cmdSearch":false,
			"cmdAllCommands":true,
			"cmdPrint":true
		}),
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0")
			]		
		}),
		"pagination":null,
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
		
	});	
	
	EmployeeWorkTimeScheduleGrid.superclass.constructor.call(this,id,options);
}

extend(EmployeeWorkTimeScheduleGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/
EmployeeWorkTimeScheduleGrid.prototype.m_month;
EmployeeWorkTimeScheduleGrid.prototype.m_employeeId;
EmployeeWorkTimeScheduleGrid.prototype.m_employeeTotal;

/* public methods */

EmployeeWorkTimeScheduleGrid.prototype.onRefresh = function(callBack){
	this.m_month = undefined;
	this.m_employeeId = undefined;
	this.m_employeeTotal = 0;
	EmployeeWorkTimeScheduleGrid.superclass.onRefresh.call(this,callBack);
}

EmployeeWorkTimeScheduleGrid.prototype.onGetData = function(resp){
	if(resp){
		this.m_model.setData(resp.getModelData(this.m_model.getId()));
	}

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
		var columns;
		
		while(this.m_model.getNextRow()){			
			
			/* header */
			if(!this.m_month||this.m_month!=this.m_model.getFieldValue("day").getMonth()){
			
				var head = this.getHead();
				var h_row = head.getElement("row0");
				h_row.delDOM();
				h_row.clear();				
				var dd = this.m_model.getFieldValue("day");
				this.m_month = dd.getMonth();				
			
				h_row.addElement(new GridCellHead(h_row.getId()+":employee",{
					"value":"ФИО",
					"colAttrs":{"style":"white-space:nowrap;"},
					"columns":[
						new GridColumn({
							"id":"employee_descr"
						})
					]
				}));		
				
				for(var i=1;i<=DateHelper.daysInMonth(dd);i++){
					h_row.addElement(new GridCellHead(h_row.getId()+":day_"+i,{
						"value":i,
						"columns":[
							new GridColumn({
								"id":"day_"+i
							})
						]
					}));		
				}
				
				h_row.addElement(new GridCellHead(h_row.getId()+":total",{
					"value":"Итого",
					"colAttrs":{"align":"right","style":"font-weight:bolder;"},
					"columns":[
						new GridColumn({
							"id":"total"
						})
					]
				}));		
				
				head.toDOM();
				
				columns = this.getHead().getColumns();
			}
			/* header */
			
			var employee_id = this.m_model.getFieldValue("employee_id");
			var day = this.m_model.getFieldValue("day");
			var col_id;
			var cell;
			
			if(!this.m_employeeId || this.m_employeeId!=employee_id){
			
				if(this.m_employeeId){
				console.log("Setting totalTo "+this.m_employeeTotal)
					cell = this.createNewCell(columns[columns.length-1],row);
					cell.setValue(this.m_employeeTotal);
					row.addElement(cell);									
				}
			
				this.m_employeeId = employee_id;
				this.m_employeeTotal = 0;
				
				row = this.createNewRow(row_cnt,h_row_ind);
				
				row.setAttr("keys",CommonHelper.serialize({"employee_id":employee_id}));			
				
				body.addElement(row);
				row_cnt++;				
				
				cell = this.createNewCell(columns[0],row);
				cell.setValue(this.m_model.getFieldValue("employee_descr"));
				row.addElement(cell);					
			}
			
			var d_ind = day.getDate();
			
			cell = this.createNewCell(columns[d_ind],row);
			var h = this.m_model.getFieldValue("hours");
			cell.setValue((h!=undefined)? h:"");
			cell.setAttr("day_off",this.m_model.getFieldValue("day_off"));
			cell.setAttr("align","center");
			cell.setAttr("day",DateHelper.format(day,"Y-m-d"));
			row.addElement(cell);					
			
			this.m_employeeTotal+= parseInt((h!=undefined)? h:"0",10);
		}
		
		if(row && this.m_employeeId){
			cell = this.createNewCell(columns[columns.length-1],row);
			cell.setValue(this.m_employeeTotal);
			row.addElement(cell);									
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

EmployeeWorkTimeScheduleGrid.prototype.edit = function(cmd,editOptions){
	if (this.m_hEdit)return;
	
	this.m_editNode = this.getSelectedNode();
	if (this.m_editNode && this.m_editNode.getAttribute("name")!="employee_descr" && this.m_editNode.getAttribute("name")!="total"){
		var self = this;
		var val = this.m_editNode.textContent;
		
		this.m_refInt = this.getRefreshInterval();
		this.setRefreshInterval(0);
		
		var keys = this.getSelectedNodeKeys();
		this.m_hEdit = new EditHour("hour_inplace_edit",{
			"employee_id":keys["employee_id"],
			"day":DOMHelper.getAttr(this.m_editNode,"day"),
			"value":val,
			"onEsc":function(){
				self.onEditComplete(true);
			},
			"onSave":function(){
				var val = self.m_hEdit.getValue();
				if (val!=self.m_hEdit.m_oldVal){
					var pm = (new Employee_Controller()).getPublicMethod("set_work_schedule_hour");
					pm.setFieldValue("employee_id",self.m_hEdit.m_employeeId);
					pm.setFieldValue("day",self.m_hEdit.m_day);
					pm.setFieldValue("hours",val);
					pm.run({
						"ok":function(resp){
							self.onEditComplete();
						},
						"fail":function(resp,errCode,errStr){
							self.onEditComplete(true);
							throw Error(errStr);
						}
					});
				}
				else{
					//same value
					self.onEditComplete(true);
				}
			}
		});
		this.m_editNode.textContent="";
		this.m_hEdit.toDOM(this.m_editNode);
		this.m_hEdit.m_node.focus();
		this.m_hEdit.m_node.setSelectionRange(0,val.length,"backward");
	}
}

EmployeeWorkTimeScheduleGrid.prototype.onEditComplete = function(esc){
	var n = this.m_hEdit.m_node.parentNode;
	var val = esc? this.m_hEdit.m_oldVal : this.m_hEdit.getValue();
	this.m_hEdit.delDOM();
	delete this.m_hEdit;
	
	this.m_editNode.textContent = val;
	this.setRefreshInterval(this.m_refInt);						
}

/**
 * 
 */
function EditHour(id,options){
	var self = this;
	options.attrs = {};
	options.maxLength = 3;	
	options.cmdClear = false;
	
	this.m_oldVal = options.value;
	this.m_employeeId = options.employee_id;
	this.m_day = options.day;
	this.m_onSave = options.onSave;
	this.m_onEsc = options.onEsc;
	
	EditHour.superclass.constructor.call(this,id,options);	
}
extend(EditHour,EditNum);

EditHour.prototype.toDOM = function(parent){
	EditHour.superclass.toDOM.call(this,parent);
	var self = this;
	EventHelper.add(this.m_node,"keydown",function(event){
		event = EventHelper.fixMouseEvent(event);
		var key_code = (event.charCode) ? event.charCode : event.keyCode;
		if (key_code==13){
			self.m_onSave();
		}
		else if (key_code==27){
			self.m_onEsc();
		}		
	});
}
