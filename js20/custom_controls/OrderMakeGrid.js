/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends GridAjx
 * @requires core/extend.js
 * @requires controls/GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function OrderMakeGrid(id,options){
	options = options || {};	
	
	this.m_listView = options.listView;
	this.m_stepMin = parseInt(options.stepMin,10);
	this.m_shiftStartMS = DateHelper.timeToMS(options.shiftStart);
	this.m_shiftLengthMS = DateHelper.timeToMS(options.shiftLength);
	this.m_periodSelect = options.periodSelect;
	var self = this;
	
	var w = window.getWidthType();
	
	var model = options.model;
	
	var role = window.getApp().getServVar("role_id");
	var editable = (role=="admin"||role=="owner"||role=="boss"||role=="manager"||role=="accountant"||role=="sales"||role=="plant_director"||role=="supervisor"||role=="dispatcher");

	var elements,foot;
	if(w=="sm"||w=="xs"){
		elements = [
			new GridCellHead(id+":order_make_grid:head:date_time_time",{
				"value":"Время",
				"colAttrs":{"align":"center"},
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_time"),
						"dateFormat":"H:i"
					})
				]
			})
		
			,new GridCellHead(id+":order_make_grid:head:inf1",{
				"value":"Клиент",
				"colAttrs":{"data-label":"Клиент"},
				"columns":[
					new GridColumn({
						"id":"inf1",
						"formatFunction":function(fields,cell){
							var res = String.fromCharCode(10)+window.getApp().formatCell(fields.clients_ref,cell,self.m_listView.COL_CLIENT_LEN);
							res+= String.fromCharCode(10)+window.getApp().formatCell(fields.destinations_ref,cell,self.m_listView.COL_DEST_LEN);
							res+= String.fromCharCode(10);
							var tel = fields.phone_cel.getValue();
							var tel_m = tel;
							if(tel_m && tel_m.length==10){
								tel_m = "+7"+tel;
							}
							else if(tel_m && tel_m.length==11){
								tel_m = "+7"+tel.substr(1);
							}
							
							var cell_n = cell.getNode();
							var c_tag = document.createElement("SPAN");
							c_tag.textContent = res;
							cell_n.appendChild(c_tag);
							
							if(tel_m && tel_m.length){
								var t_tag = document.createElement("A");
								t_tag.setAttribute("href","tel:"+tel_m);
								t_tag.textContent = CommonHelper.maskFormat(tel,window.getApp().getPhoneEditMask());
								cell_n.appendChild(t_tag);
							}
							return "";
						}
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:inf3",{
				"value":"Насос",
				"colAttrs":{"data-label":"Насос"},
				"columns":[
					new GridColumn({
						"id":"inf3",
						"formatFunction":function(fields,cell){
							var res = "";
							var unl_t = fields.unload_type.getValue();
							if(unl_t=="band"||unl_t=="pump"){
								var cmt = fields.pump_vehicle_comment.getValue();
								//String.fromCharCode(10)+
								res+= (unl_t=="band"? "Лента":"Насос")+":"+String.fromCharCode(10);
								res+= window.getApp().formatCell(fields.pump_vehicle_owners_ref,cell,self.m_listView.COL_PUMP_VEH_LEN-4);
								var l = fields.pump_vehicle_length.getValue();
								if(l){
									res+="("+l+((cmt&&cmt.length)? ","+cmt:"")+")";
								}
								else if(cmt&&cmt.length){
									res+="("+cmt+")";
								}
							}
						
							return res;
						}
					})
				]
			})
			
			,new GridCellHead(id+":order_make_grid:head:inf2",{
				"value":"Кол-во,марка",
				"colAttrs":{"data-label":"Кол-во,марка"},
				"columns":[
					new GridColumn({
						"id":"inf2",
						"formatFunction":function(fields,cell){
							var res = fields.quant.getValue();
							res+= String.fromCharCode(10)+fields.concrete_types_ref.getValue().getDescr();
							return res;
						}
					})
				]
			})
		];
	}
	else{
		elements = [
			new GridCellHead(id+":order_make_grid:head:quant_rest",{
				"value":"Ост.",
				"columns":[
					new GridColumn({
						"field":model.getField("quant_rest"),
						"master":true,
						"detailViewClass":ShipmentForOrderList_View,
						"detailViewOptions":{
							"listView":self.m_listView,
							"detailFilters":{
								"ShipmentForOrderList_Model":[
									{
									"masterFieldId":"id",
									"field":"order_id",
									"sign":"e",
									"val":"0"
									}	
								]
							}													
						}
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:clients_ref",{
				"value":"Клиент",
				"columns":[
					new GridColumn({
						"field":model.getField("clients_ref"),
						"formatFunction":function(fields,cell){
							return window.getApp().formatCell(fields.clients_ref,cell,self.m_listView.COL_CLIENT_LEN);
						}
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:destinations_ref",{
				"value":"Объект",
				"columns":[
					new GridColumn({
						"field":model.getField("destinations_ref"),
						"formatFunction":function(fields,cell){
							return window.getApp().formatCell(fields.destinations_ref,cell,self.m_listView.COL_DEST_LEN);
						}
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:quant",{
				"value":"Кол-во",
				"colAttrs":{"align":"center"},
				"columns":[
					new GridColumn({
						"field":model.getField("quant")
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:concrete_types_ref",{
				"value":"Марка",
				"colAttrs":{"align":"center"},
				"columns":[
					new GridColumnRef({
						"field":model.getField("concrete_types_ref")
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:date_time_time",{
				"value":"Время",
				"colAttrs":{"align":"center"},
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_time"),
						"dateFormat":"H:i"
					})
				]
			})
			
			,new GridCellHead(id+":order_make_grid:head:unload_type",{
				"value":"Подача",
				"columns":[
					new GridColumn({
						"field":model.getField("unload_type"),
						"formatFunction":function(fields,cell){
							var res = "";
							var tp = fields.unload_type.getValue();
							if(tp=="band"||tp=="pump"){
								var cmt = fields.pump_vehicle_comment.getValue();
								res = window.getApp().formatCell(fields.pump_vehicle_owners_ref,cell,self.m_listView.COL_PUMP_VEH_LEN-4);
								var l = fields.pump_vehicle_length.getValue();
								if(l){
									res+="("+l+((cmt&&cmt.length)? ","+cmt:"")+")";
								}
								else if(cmt&&cmt.length){
									res+="("+cmt+")";
								}
							}
							return res;
						}
					})
				]
			})
			,!editable? null:new GridCellHead(id+":order_make_grid:head:total",{
				"value":"Сумма",
				"colAttrs":{"align":"right"},
				"columns":[
					new GridColumn({
						"field":model.getField("total"),
						"formatFunction":function(fields){
							var res = "";
							if(fields.pay_cash.getValue()){
								res = CommonHelper.numberFormat(fields.total.getValue(),2,","," ");
							}
							return res;
						}
					})
				]
			})
		
			,!editable? null:new GridCellHead(id+":order_make_grid:head:payed",{
				"value":"Оплата",
				"colAttrs":{"align":"center"},
				"columns":[
					new GridColumn({
						"field":model.getField("payed"),
						"formatFunction":function(fields){
							var res = "";
							if(fields.payed.getValue()){
								res = "опл";
							}
							else if(fields.under_control.getValue()){
								res = "!";
							}
							else{
								res = "-";
							}
							return res;
						}
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:comment_text",{
				"value":"Комментарий",
				"columns":[
					new GridColumn({
						"field":model.getField("comment_text"),
						"formatFunction":function(fields,cell){
							return window.getApp().formatCell(fields.comment_text,cell,self.m_listView.COL_COMMENT_LEN);
						}										
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:phone_cel",{
				"value":"Телефон",
				"columns":[
					new GridColumnPhone({
						"field":model.getField("phone_cel"),
						"telExt":window.getApp().getServVar("tel_ext")
					})
				]
			})
			,new GridCellHead(id+":order_make_grid:head:descr",{
				"value":"Прораб",
				"columns":[
					new GridColumn({
						"field":model.getField("descr"),
						"formatFunction":function(fields,cell){
							return window.getApp().formatCell(fields.descr,cell,self.m_listView.COL_DESCR_LEN);
						}										
					})
				]
			})
			,(role!="lab_worker")? null:new GridCellHead(id+":order_make_grid:head:is_needed",{
				"value":"Нужно",
				"columns":[
					new GridColumn({
						"field":model.getField("is_needed"),
						"assocValueList":{
							"true":"нужно",
							"null":"",
							"false":""
						}
					})
				]
			})

		];
		foot = new GridFoot(id+"order_make_grid:foot",{
			"autoCalc":true,			
			"elements":[
				new GridRow(id+":order_make_grid:foot:row0",{
					"elements":[
						new GridCellFoot(id+":order_make_grid:foot:tot_quant_rest",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"quant_rest",
							"gridColumn":new GridColumnFloat({"id":"tot_quant_rest"})
						})						
						,new GridCell(id+":order_make_grid:foot:total_sp1",{
							"colSpan":"2"
						})						
						,new GridCellFoot(id+":order_make_grid:foot:tot_quant",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"quant",
							"gridColumn":new GridColumnFloat({"id":"tot_quant"}),
							"calc":function(model){
								var ct_ref = model.getFieldValue("concrete_types_ref");
								if(ct_ref&&ct_ref.getDescr()!="Вода"){
									var f_val = model.getFieldValue(this.m_calcFieldId);
									if(isNaN(f_val))f_val = 0;
	
									this.setTotal(this.getTotal()+f_val);							
								}
							}
						})						
						,new GridCell(id+":order_make_grid:foot:total_sp2",{
							"colSpan":"3"
						})						
						,!editable? null:new GridCellFoot(id+":order_make_grid:foot:tot_total",{
							"attrs":{"align":"right"},
							"calcOper":"sum",
							"calcFieldId":"total",
							"gridColumn":new GridColumnFloat({"id":"tot_total"})
						})						
				
						,new GridCell(id+":order_make_grid:foot:total_sp3",{
							"colSpan":"4"
						})						
				
					]
				})		
			]
		});		
	};
		
	CommonHelper.merge(options,{
		"model":model,
		"attrs":{"style":"width:100%;"},
		"editInline":false,
		//"editWinClass":OrderDialog_Form,
		"editViewClass":OrderDialog_View,
		"commands":new GridCmdContainerAjx(id+":order_make_grid:cmd",{
			"cmdInsert":editable,
			"cmdDelete":editable,
			"cmdCopy":editable,
			"cmdEdit":true,
			"cmdSearch":false,
			"cmdExport":false
		}),
		"editViewOptions":{
			"template":window.getApp().getTemplate("OrderDialogView")
		},
		"insertViewOptions":function(){
			return {
				"template":window.getApp().getTemplate("OrderDialogView"),
				"dateTime_time":self.m_dateTime_time,
				"dateTime_date":self.dateTime_date
			}
		},
		"onEventSetCellOptions":function(opts){
			if(window.getWidthType()=="sm"){
				opts.attrs = opts.attrs || {};
				opts.attrs.style = "white-space:pre-wrap; word-wrap:break-word;";
			}
		},
		"onEventSetRowOptions":function(opts){
			opts.className = opts.className||"";
			var m = this.getModel();
			var quant_rest = m.getFieldValue("quant_rest");
			var quant = m.getFieldValue("quant");
							
			if(quant_rest==0){
				opts.className+= (opts.className.length? " ":"")+"order_closed";
			}
			else if (quant_rest==quant
			&&m.getFieldValue("date_time").getTime()<(DateHelper.time()).getTime() ){
				opts.className+= (opts.className.length? " ":"")+"order_not_started";
			}
			else if (quant_rest!=quant){
				opts.className+= (opts.className.length? " ":"")+"order_started";
			}
			
			//&&quant_rest&&quant_rest!=quant
			if (m.getFieldValue("no_ship_mark")){
				opts.className+= (opts.className.length? " ":"")+"order_no_ship_for_long";
			}
			
			self.m_listView.m_orderedTotal+= quant;
			self.m_listView.m_restTotal+= quant_rest;
			self.m_listView.m_shippedTotal+= (quant-quant_rest);
			self.m_listView.m_orderedSum+= m.getFieldValue("total");
			self.m_listView.m_orderedDay+= m.getFieldValue("quant_ordered_day");
			
			self.m_listView.m_orderedBeforeNow+= m.getFieldValue("quant_ordered_before_now");
			self.m_listView.m_shippedBeforeNow+= m.getFieldValue("quant_shipped_before_now");
			self.m_listView.m_shippedDayBeforeNow+= m.getFieldValue("quant_shipped_day_before_now");
			
			/*
			time = DateHandler.timeToSeconds(
				model.getFieldById('date_time_time_descr').getValue())/60;				
			var norm_on_time = (time-(self.m_listView.FIRST_SHIFT_START))*50/60;
			if (self.m_listView.m_orderedTotal>norm_on_time){
				opts.className+= (opts.className.length? " ":"")+"order_overload";
			}
			*/
										
		},
		"popUpMenu":new PopUpMenu(),
		"head":new GridHead(id+":order_make_grid:head",{
			"elements":[
				new GridRow(id+":order_make_grid:head:row0",{
					"elements":elements
				})
			]
		}),
		"foot":foot,
		"selectedRowClass":"order_current_row",
		"pagination":null,
		"autoRefresh":false,
		"refreshInterval":null,
		"navigate":true,
		"rowSelect":true,
		"focus":true
	});
	
	OrderMakeGrid.superclass.constructor.call(this,id,options);
}

extend(OrderMakeGrid,Grid);

/* Constants */


/* private members */

/* protected*/


/* public methods */

OrderMakeGrid.prototype.onGetData = function(){
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
		
		//*** ADDED missing rows ****
		var shift_start_time = this.m_periodSelect.getDateFrom();
		var now = DateHelper.time();
		var now_shift_start = DateHelper.getStartOfShift();
		var prev_time_m,init_time_m;
		var future_shift;
		var now_m = now.getHours()*60 + now.getMinutes();
		
		//console.log("shift_start_time="+shift_start_time)
		if(now.getTime() < shift_start_time.getTime()){
			//future shift
			future_shift = true;
			prev_time_m = shift_start_time.getHours()*60 + shift_start_time.getMinutes();
		}
		else{
			//round now to stepMin
			future_shift = false;
			now.setMinutes(Math.ceil(now.getMinutes() / this.m_stepMin) * this.m_stepMin);
			prev_time_m = now.getHours()*60 + now.getMinutes();
		}
		init_time_m = prev_time_m;
		
		var model_ind = 0;
		//console.log("StartTime="+prev_time_m)
		//*** ADDED ****
		
		var closed_shift;
		while(this.m_model.getNextRow()){			
			//*** ADDED missing rows ****
			var dt = this.m_model.getFieldValue("date_time");
			if(row_cnt==0){
				closed_shift = (dt.getTime()<now_shift_start.getTime());
			}
			var dt_m = dt.getHours()*60 + dt.getMinutes();
			var comp_time_m = (init_time_m>prev_time_m)? init_time_m:prev_time_m;
			if(!closed_shift && dt_m>comp_time_m && (future_shift || now_m<dt_m) ){
				row_cnt = this.addEmptyRows(comp_time_m,dt_m,columns,row_cnt);				
			}
			prev_time_m = dt_m + this.m_stepMin;
			//*** ADDED ****
			
			row = this.createNewRow(row_cnt,h_row_ind,model_ind);			
			model_ind++;
			
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
		
		//ADDED
		var mm = this.m_shiftLengthMS/60/1000;
		if(!closed_shift && prev_time_m<mm && (future_shift || now_m<prev_time_m) ){
			this.addEmptyRows(prev_time_m,mm,columns,row_cnt);
		}			
		//ADDED
		
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

OrderMakeGrid.prototype.createNewRow = function(rowCnt,hRowInd,modelIndex){
	var r_class = this.getHead().getRowClass(hRowInd);
	var row_opts;
	var opts = this.getHead().getRowOptions();	
	if (typeof(opts)=="function"){
		row_opts = opts.call(this);
	}
	else{
		row_opts = CommonHelper.clone(opts);
	}
	//
	row_opts.attrs = row_opts.attrs || {};
	
	row_opts.attrs.modelIndex = modelIndex;
	
	if (this.m_onSelect){
		row_opts.className+= ( row_opts.className? " ":"") +"for_select"; 
	}
	
	if (this.m_onEventSetRowOptions){
		//model can be accessed with this.getModel()
		this.m_onEventSetRowOptions(row_opts);
	}
	
	if (this.m_onEventSetRowClass){
		//Do not use!!!
		this.m_onEventSetRowClass(this.m_model,row_opts.className);
	}

	/*
	if (this.m_onSelect){
		row_opts.events = row_opts.events || {};
		row_opts.events.click = function(){
			self.m_onSelect();
		}
	}
	*/
	var row;
	if (r_class.name=="Control" || r_class.name=="ControlContainer"){		
		row = new r_class(this.getId()+":"+this.getBody().getName()+":"+rowCnt,row_opts.tagName||"DIV",row_opts);
	}
	else{
		row = new r_class(this.getId()+":"+this.getBody().getName()+":"+rowCnt,row_opts);
	}
	return row;
}

OrderMakeGrid.prototype.addEmptyRows = function(fromMin,toMin,columns,rowCnt){	
//console.log("OrderMakeGrid.prototype.addEmptyRows fromMin="+fromMin+" toMin="+toMin+" this.m_stepMin="+this.m_stepMin)
	var date_start = DateHelper.dateStart(this.m_periodSelect.getDateFrom());
	var row;
	var self = this;
	var row_pref = this.getId()+":"+this.getBody().getName()+":";
	//this.m_emptyClicks = {};
	for (var m=fromMin;m<toMin;m+=this.m_stepMin){
	
		var h = Math.floor(m/60);
		var mm = m - h*60;
		var value = ((h<10)? "0":"")+h+":"+((mm<10)? "0":"")+mm;
		/*
		this.m_emptyClicks[row_pref+rowCnt] = function(time,d){
			var win_id = CommonHelper.uniqid();
			var win_params = {
					"id":win_id,
					"onClose":function(res){
						//set element current if ok
						res = res || {"updated":false};
						self.closeEditWinObj(res,this.getId());
					},
					"keys":null,
					"params":{
						"cmd":"insert",
						"editViewOptions":{
							"dateTime_time":time,
							"dateTime_date":d
						}
					}
			};
			//can be a function!
			var edit_cl  = (self.m_editWinClass.name=="editWinClass")? self.m_editWinClass.call(self,win_params) : self.m_editWinClass;
			self.m_editWinObjList[win_id] = new edit_cl(win_params);	
			self.m_editWinObjList[win_id].open();
		
		}
		*/
		row  = new GridRow(row_pref+rowCnt,{
			"className":"emptyRow",
			"attrs":{
				"keys":("empty_"+rowCnt),
				"time":value
			}
		});
		
		var field_cnt = 0,cell,cell_opts;
		for (var col_id=0;col_id<columns.length;col_id++){
			columns[col_id].setGrid(this);

			cell_opts = {};
			if(columns[col_id].getId()=="date_time"){
				var h = Math.floor(m/60);
				var mm = m - h*60;
				cell_opts.attrs = {"align":"center"};
				cell_opts.value = value;
			}

			cell = new GridCell(null,cell_opts);				
			
			row.addElement(cell);
							
			field_cnt++;				
		}
		
		this.getBody().addElement(row);
		rowCnt++;
	}
	return rowCnt;
}

OrderMakeGrid.prototype.onEditSelect = function(event){	
	var tr = DOMHelper.getParentByTagName(event.target,"TR");
	if(tr&&DOMHelper.hasClass(tr,"emptyRow")){
		var self = this;
		/*
		var win_id = CommonHelper.uniqid();
		var win_params = {
				"id":win_id,
				"onClose":function(res){
					//set element current if ok
					res = res || {"updated":false};
					self.closeEditWinObj(res,this.getId());
				},
				"keys":null,
				"params":{
					"cmd":"insert",
					"editViewOptions":{
						"dateTime_time":tr.getAttribute("time"),
						"dateTime_date":this.m_periodSelect.getDateFrom()
					}
				}
		};
		//can be a function!
		var edit_cl  = (self.m_editWinClass.name=="editWinClass")? self.m_editWinClass.call(self,win_params) : self.m_editWinClass;
		self.m_editWinObjList[win_id] = new edit_cl(win_params);	
		self.m_editWinObjList[win_id].open();
	
		//this.m_emptyClicks[tr.id].call(this,tr.getAttribute("time"),this.m_periodSelect.getDateFrom());
		*/
		this.m_dateTime_time = tr.getAttribute("time");
		this.dateTime_date = this.m_periodSelect.getDateFrom();
		
		var parent = this.getNode().parentNode.parentNode;
		this.m_oldParent = this.getNode().parentNode.parentNode;
		this.initEditView(parent, null,"insert");	
		this.delDOM();
		this.editViewToDOM(parent,null,"insert");
		this.fillEditView("insert");		
	}
	else{
		return OrderMakeGrid.superclass.onEditSelect.call(this,event);
	}
}

OrderMakeGrid.prototype.keysToPublicMethod = function(pm){
	var pm_fields = pm.getFields();
	var fields = this.m_model.getFields();
	for (id in pm_fields){
		if (fields[id] && fields[id].getPrimaryKey()){
			var v = fields[id].getValue();
			pm_fields[id].setValue(v);
		}
		else if (pm_fields[id].getPrimaryKey()){
			pm_fields[id].resetValue();
		}
	}
}

/* Completely overridden function */
OrderMakeGrid.prototype.delRow = function(rowNode){
	var pm = (new Order_Controller()).getPublicMethod("delete");

	this.setEnabled(false);
	
	this.setModelToCurrentRow();	
	this.keysToPublicMethod(pm);
	var self = this;
	pm.run({
		"async":false,
		"ok":function(){
			self.afterServerDelRow();
		},
		"fail":function(resp,erCode,erStr){
			self.setEnabled(true);
			self.onError(resp,erCode,erStr);
		}
	});	
}

OrderMakeGrid.prototype.fillEditView = function(cmd){
	if (cmd!="insert"){
		this.keysToPublicMethod(this.m_editViewObj.getReadPublicMethod());
	}
	
	OrderMakeGrid.superclass.fillEditView.call(this,cmd);
}

OrderMakeGrid.prototype.afterServerDelRow = function(){
	this.deleteRowNode();
	this.setEnabled(true);			
	var self = this;
	window.showTempNote("Заявка удалена",function(){
		self.focus();
		self.onRefresh();
	},2000);			
}
/*
OrderMakeGrid.prototype.delDOM = function(){
	if(this.m_periodSelect)this.m_periodSelect.delDOM();
	OrderMakeGrid.superclass.delDOM.call(this);
}

OrderMakeGrid.prototype.toDOM = function(p){
	if(this.m_periodSelect)this.m_periodSelect.toDOM(document.getElementById("OrderMakeList:colLeft"));
	OrderMakeGrid.superclass.toDOM.call(this,p);
}
*/
