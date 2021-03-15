/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OperatorList_View(id,options){	

	options.templateOptions = options.templateOptions || {};
	options.templateOptions.showPeriod = (!options.fromLabList && CommonHelper.inArray(window.getApp().getServVar("role_id"),["operator","dispatcher"])==-1);
	
	var constants = {"order_grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
		
	//events
	options.srvEvents =
		options.fromLabList? null
		:{
		"events":[
			{"id": "Shipment.insert"}
			,{"id": "Shipment.update"}
			,{"id": "Shipment.delete"}
			,{"id": "Production.insert"}
			,{"id": "Production.update"}
			,{"id": "Production.delete"}
			],
		"onEvent": function(json){
				var do_refresh = true;
				
				var grid = self.getElement("grid");
				//Shipment
				if(json.controllerId=="Shipment"&& (json.methodId=="update"||json.methodId=="delete" ) ){
					//look for id
					
					var keys = grid.getKeyIds();
					var key_fields = {};
					for(var i=0;i<keys.length;i++){
						if(json.params[keys[i]]){
							key_fields[keys[i]] = json.params[keys[i]];
						}
					}
					try{
						grid.m_model.recLocate(key_fields,true);
					}
					catch(e){
						do_refresh = false;
					}
					
				}
				else if(json.controllerId=="Production"&& (json.methodId=="update"||json.methodId=="delete" )){
					do_refresh = false;
					grid.m_model.reset();
					while(grid.m_model.getNextRow()){
						var list = grid.m_model.getFieldValue("production_list");
						if(list){
							for(var i=0;i<list.length;i++){
								if(list[i].id==json.params.id){
									do_refresh = true;
									break;	
								}
							}
						}					
					}
				}
				
				if(do_refresh){
					grid.onRefresh();
				}				
			}
		,"onSubscribed": function(){
			self.getElement("grid").setRefreshInterval(0);
		}
		,"onClose": function(message){
			self.getElement("grid").setRefreshInterval(self.m_httpRefreshInterval);
		}		
		};
	this.m_httpRefreshInterval = constants.order_grid_refresh_interval.getValue()*1000;
	
	OperatorList_View.superclass.constructor.call(this,id,options);
	
	//Для оператора - только текущая смена, для все остальных - можно шагазть по сменам	
	if(options.templateOptions.showPeriod){
		var cur = DateHelper.time();		
		var per_select = new EditPeriodShift(id+":date_filter",{
			"template":window.getApp().getTemplate( ((window.getWidthType()=="sm")? "EditPeriodShiftSM":"EditPeriodShift") ),
			"dateFrom":(new Date(cur.getFullYear(),cur.getMonth(),cur.getDate())),
			"onChange":function(dateTime){
				var gr = self.getElement("grid");
				gr.getReadPublicMethod().setFieldValue("date",dateTime);
				window.setGlobalWait(true);
				gr.onRefresh(function(){
					window.setGlobalWait(false);
				});
			}
		});
		this.addElement(per_select);	
	}
		
	var model = options.models.OperatorList_Model;
	this.m_totModel = options.models.OperatorTotals_Model;
	this.m_prodSiteModel = options.models.OperatorProductionSite_Model;
	var contr = new Shipment_Controller();
	
	var self = this;
	var elements = [
		new GridCellHead(id+":grid:head:production_id",{
			"value":"№ произ-ва",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumn({
					"field":model.getField("production_list")
					,"formatFunction":function(fields,gridCell){
						var list = fields.production_list.getValue();
						if(list){
							var col = gridCell.getGridColumn();
							col.productions = col.productions || [];
							var cell_n = gridCell.getNode();
							for(var i=0;i<list.length;i++){
								var t_tag_cont = document.createElement("DIV");
								//t_tag_cont.setAttribute("class",list[i].material_tolerance_violated? "badge badge-danger":"operatorProdDetail");
								
								col.productions[list[i].production_id] = {
									"pic":document.createElement("SPAN")
									,"txt":document.createElement("SPAN")
								};
								col.productions[list[i].production_id].pic.setAttribute("class","glyphicon glyphicon-triangle-right pull-left detailToggle");
								if(list[i].material_tolerance_violated){
									col.productions[list[i].production_id].txt.setAttribute("class","badge badge-danger");
									col.productions[list[i].production_id].txt.setAttribute("style","font-size:100%;");
								}
								col.productions[list[i].production_id].txt.textContent = list[i].production_id;
								
								t_tag_cont.appendChild(col.productions[list[i].production_id].pic);
								t_tag_cont.appendChild(col.productions[list[i].production_id].txt);
								cell_n.appendChild(t_tag_cont);								
								
								EventHelper.add(col.productions[list[i].production_id].pic, "click",(function(prodData){
									return function(e){
										EventHelper.stopPropagation(e);
										
										self.showProdDetails(prodData,e.target);
									}
								})(list[i])
								);
								
								col.productions[list[i].production_id].tooltip = new ToolTip({
										"node":t_tag_cont,
										"wait":500,
										"onHover":(function(prodData,toolTip){
											return function(ev){
												self.showProdTooltip(this,prodData,ev);
												
											}										
										}
										)(list[i],col.productions[list[i].production_id].tooltip)
									});
							}
						}
						return "";
					}
					/*,"master":true,
					"detailViewClass":ProductionMaterialList_View,
					"detailViewOptions":{
						"detailFilters":{
							"ProductionMaterialList_Model":[
								{
								"masterFieldId":"production_site_id",
								"field":"production_site_id",
								"sign":"e",
								"val":"0"
								}	
								,{
								"masterFieldId":"production_id",
								"field":"production_id",
								"sign":"e",
								"val":"0"
								}	
								
							]
						}													
					}																											
					*/
				})
			]
		})
	
		,new GridCellHead(id+":grid:head:date_time",{
			"value":"Назначен",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("date_time"),
					"dateFormat":"H:i"
				})
			]
		})
		,new GridCellHead(id+":grid:head:ship_date_time",{
			"value":"Отгружен",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("ship_date_time"),
					"dateFormat":"H:i"
				})
			]
		})
		,new GridCellHead(id+":grid:head:production_sites_ref",{
			"value":"Завод",
			"columns":[
				new GridColumnRef({
					"field":model.getField("production_sites_ref"),
					"formatFunction":function(f){
						var res = "";
						if(f.production_sites_ref && !f.production_sites_ref.isNull()){
							res = f.production_sites_ref.getValue().getDescr();
						}
						if(f.operators_ref && !f.operators_ref.isNull()){
							res+=" "+f.operators_ref.getValue().getDescr();
						}
						return res;
					}
				})
			]
		})		
		,new GridCellHead(id+":grid:head:clients_ref",{
			"value":"Клиент",
			"columns":[
				new GridColumnRef({
					"field":model.getField("clients_ref")
				})
			]
		})
		,new GridCellHead(id+":grid:head:destinations_ref",{
			"value":"Объект",
			"columns":[
				new GridColumnRef({
					"field":model.getField("destinations_ref")
				})
			]
		})
		,new GridCellHead(id+":grid:head:comment_text",{
			"value":"Комментарий",
			"columns":[
				new GridColumn({
					"field":model.getField("comment_text")
				})
			]
		})		
		,new GridCellHead(id+":grid:head:quant",{
			"value":"Кол-во",
			"colAttrs":{"align":"right"},
			"columns":[
				new GridColumnFloat({
					"field":model.getField("quant"),
					"precision":1
				})
			]
		})
		,new GridCellHead(id+":grid:head:concrete_types_ref",{
			"value":"Марка",
			"colAttrs":{"align":"right"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("concrete_types_ref")
					/*,"formatFunction":function(fields,gridCell){
						var res = "";
						var ct = fields.concrete_types_ref.getValue();	
						var p_ct = fields.production_concrete_types_ref.getValue();
						//var p_ct = new RefType({"descr":"M350","keys":{"id":"111"}});
						if(!p_ct.isNull()){
							 if(!ct.isNull()){
								 res = ct.getDescr();
								 if(ct.getKey("id")!=p_ct.getKey("id")){
								 	res+="/"+p_ct.getDescr();
									 gridCell.setAttr("title","Другая марка Elkon!");
									 DOMHelper.addClass(gridCell.getNode(),"elkonDifConcreteType");
								 }
							}							
						}
						else{							 
							 if(!ct.isNull()){
								 res = ct.getDescr();
							}
						}
						return res;
					}
					*/
				})
			]
		})
		,new GridCellHead(id+":grid:head:vehicles_ref",{
			"value":"ТС",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("vehicles_ref"),
					"formatFunction":function(f){
						var v = (f&&f.vehicles_ref&&!f.vehicles_ref.isNull())? f.vehicles_ref.getValue().getDescr():"";
						var res = "";
						var ch;
						for(var i=0;i<v.length;i++){
							ch = v.charCodeAt(i);
							if(ch>=48 && ch<=57){
								res+=v[i];
							}
						}
						return res;
					}
				})
			]
		})
		,new GridCellHead(id+":grid:head:drivers_ref",{
			"value":"Водитель",
			"columns":[
				new GridColumnRef({
					"field":model.getField("drivers_ref")
				})
			]
		})							
	];
	var foot_elements = [
		new GridCell(id+":grid:foot:sp1",{
			"colSpan":"7"
		})												
		,new GridCellFoot(id+":features_grid:foot:tot_quant",{
			"attrs":{"align":"right"},
			"calcOper":"sum",
			"calcFieldId":"quant",
			"gridColumn":new GridColumnFloat({
				"id":"tot_quant",
				"precision":1
			})
		})						
	];
	
	
	var role = window.getApp().getServVar("role_id");
	if(role!="operator"){
		elements.push(
			new GridCellHead(id+":grid:head:ship_norm_min",{
				"value":"Норма отгр.",
				"colAttrs":{"align":"right"},
				"columns":[
					new GridColumnFloat({
						"field":model.getField("ship_norm_min")
					})
				]
			})		
		);
		elements.push(
			new GridCellHead(id+":grid:head:ship_fact_min",{
				"value":"Норма факт.",
				"colAttrs":{"align":"right"},
				"columns":[
					new GridColumnFloat({
						"field":model.getField("ship_fact_min")
					})
				]
			})
		);
		elements.push(
			new GridCellHead(id+":grid:head:ship_bal_min",{
				"value":"Ост.",
				"colAttrs":{"align":"right"},
				"columns":[
					new GridColumnFloat({
						"field":model.getField("ship_bal_min")
					})
				]
			})		
		);
		
		foot_elements.push(
			new GridCell(id+":grid:foot:sp2",{
				"colSpan":"3"
			})												
		
		);
		foot_elements.push(
			new GridCellFoot(id+":features_grid:foot:tot_ship_norm_min",{
				"attrs":{"align":"right"},
				"calcOper":"sum",
				"calcFieldId":"ship_norm_min",
				"gridColumn":new GridColumn({"id":"tot_ship_norm_min"})
			})						
		);
		foot_elements.push(
			new GridCellFoot(id+":features_grid:foot:tot_ship_fact_min",{
				"attrs":{"align":"right"},
				"calcOper":"sum",
				"calcFieldId":"ship_fact_min",
				"gridColumn":new GridColumn({"id":"tot_ship_fact_min"})
			})						
		);
		foot_elements.push(
			new GridCellFoot(id+":features_grid:foot:tot_ship_bal_min",{
				"attrs":{"align":"right"},
				"calcOper":"sum",
				"calcFieldId":"ship_bal_min",
				"gridColumn":new GridColumn({"id":"tot_ship_bal_min"})
			})						
		);
		
	}

	if(role=="operator"||role=="owner"||role=="boss"){
		elements.push(
			new GridCellHead(id+":grid:head:sys",{
				"value":"...",
				"columns":[
					new GridColumn({
						"id":"sys",
						"cellElements":[
							{"elementClass":ButtonCtrl,
							"elementOptions":{
									"title":"Отгрузить",
									"glyph":"glyphicon-send",
									"onClick":function(){
										self.setShipped(this);
									}						
								}
							}
							,{"elementClass":PrintInvoiceBtn}
						]
					})
				]
			})		
		);
	}
	
	var grid = new GridAjx(id+":grid",{
		"className":"table-bordered table-responsive table-make_order",
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_operator_list"),
		"editInline":false,
		"editWinClass":null,
		"commands":null,
		"popUpMenu":null,
		"cmdInsert":false,
		"cmdEdit":false,
		"cmdDelete":false,
		
		
		"onEventSetRowOptions":function(opts){
			opts.className = opts.className||"";
			var m = this.getModel();
			if (m.getFieldValue("shipped")){
				opts.className+= (opts.className.length? " ":"")+"shipped";
			}
		},
		"onEventSetCellOptions":function(opts){
			opts.className = opts.className||"";
			var col = opts.gridColumn.getId();
			var m = this.getModel();
			if (!m.getFieldValue("shipped") && (col=="concrete_types_ref"||col=="quant") ){
				opts.className+= (opts.className.length? " ":"")+"operatorNotShipped";
			}
			else if(
				col=="production_list"
				&&(
					//( m.getFieldValue("tolerance_exceeded")||(m.getFieldValue("shipped") && !m.getFieldValue("production_id")) )
					(m.getFieldValue("production_quant") && m.getFieldValue("production_quant")!=m.getFieldValue("quant"))
				)
			){
				opts.className+= (opts.className.length? " ":"")+"factQuantViolation";
				opts.title = "Объем по данным производства: "+m.getFieldValue("production_quant")+"м3";
			}
		},
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":elements
				})
			]
		}),
		"foot":new GridFoot(id+":grid:foot",{
			"autoCalc":true,			
			"elements":[
				new GridRow(id+":grid:foot:row0",{
					"elements":foot_elements
				})		
			]
		}),		
		"pagination":null,		
		"autoRefresh":false,
		"refreshInterval":options.fromLabList? null:this.m_httpRefreshInterval,
		"rowSelect":false,
		"focus":!options.fromLabList,
		"navigate":false,
		"navigateClick":false
	});	
	this.addElement(grid);
	
	this.m_gridOnGetData = grid.onGetData;
	grid.onGetData = function(resp){
		if(!document.getElementById(self.getId())){
			return;
		}
		if(resp){		
			self.m_totModel = resp.getModel("OperatorTotals_Model");
			self.m_prodSiteModel = resp.getModel("OperatorProductionSite_Model");
		}
		if(self.m_totModel.getNextRow()){
			var q_shipped = parseFloat(self.m_totModel.getFieldValue("quant_shipped"));
			var q_ordered = parseFloat(self.m_totModel.getFieldValue("quant_ordered"));
			document.getElementById("totShipped").value = q_shipped.toFixed(2);
			document.getElementById("totOrdered").value = q_ordered.toFixed(2);
			document.getElementById("totBalance").value = (q_ordered-q_shipped).toFixed(2);
		}
		var n = "";
		while(self.m_prodSiteModel.getNextRow()){			
			n+= (n=="")? "":", ";
			n+= self.m_prodSiteModel.getFieldValue("name");			
		}
		DOMHelper.setText(document.getElementById(self.getId()+":prod_site_title"),n);
		
		self.m_gridOnGetData.call(self.getElement("grid"),resp);
		
		//Расчет Хэша не простой  т.к. результаты производтва приходят позже и меняют данные, а пикать не надо!
		var new_data = "";//this.m_model.getData().toString();
		this.m_model.reset();
		while(this.m_model.getNextRow()){
			new_data+= this.m_model.getFieldValue("date_time")+this.m_model.getFieldValue("ship_date_time");
		}		
		var new_data_h = CommonHelper.md5(new_data);
		if(!this.m_oldDataHash || this.m_oldDataHash!=new_data_h){
			if(this.m_oldDataHash!=undefined){
				window.getApp().makeGridNewDataSound();
			}
			this.m_oldDataHash = new_data_h;
		}
		
	}
}
extend(OperatorList_View,ViewAjxList);

OperatorList_View.prototype.setShipped = function(btnCont){
	var tr = DOMHelper.getParentByTagName(btnCont.m_node,"tr");
	if(!tr){
		throw new Error("TR tag not found!");
	}
	var keys = CommonHelper.unserialize(tr.getAttribute("keys"));
	var grid = btnCont.gridColumn.getGrid();
	var pm = grid.getReadPublicMethod().getController().getPublicMethod("set_shipped");
	pm.setFieldValue("id",keys.id);
	pm.run({
		"ok":function(resp){
			grid.onRefresh();
		}
	})
}

OperatorList_View.prototype.showProdDetails = function(prodData,node){
	this.m_details = this.m_details || [];
	if(!this.m_details[prodData.production_id]){
		var detail_view_id = CommonHelper.uniqid();
		
		var tr = DOMHelper.getParentByTagName(node,"TR");
		
		this.m_detailRow = this.m_detailRow || [];
		this.m_detailRow[prodData.production_id] = document.createElement(tr.tagName);
		this.m_detailRow[prodData.production_id].className = "grid_details";
		this.m_detailRow[prodData.production_id].setAttribute("for_keys",tr.getAttribute("keys"));
		this.m_detailRow[prodData.production_id].setAttribute("detail_view_id",detail_view_id);
		
		//new 
		var v_opts = {};
		v_opts.attrs = v_opts.attrs || {};
		v_opts.attrs.style = "display: none;";
		v_opts.attrs.colspan = tr.cells.length;
		v_opts.tagName = "TD";
		
		//setting keys
		var grid = this.getElement("grid");
		this.m_gridRefreshInterval = grid.getRefreshInterval();
		grid.setRefreshInterval(0);
		
		v_opts.detailFilters = {
			"ProductionMaterialList_Model":[
				{
				"masterFieldId":"production_site_id",
				"field":"production_site_id",
				"sign":"e",
				"val":prodData.production_site_id
				}	
				,{
				"masterFieldId":"production_id",
				"field":"production_id",
				"sign":"e",
				"val":prodData.production_id
				}	
				
			]		
		};
		
		var app = window.getApp();
		if(!app.m_detailViews)app.m_detailViews = {};
		app.m_detailViews[detail_view_id] = new ProductionMaterialList_View(detail_view_id,v_opts);
		
		if(tr.nextSibling){
			tr.parentNode.insertBefore(this.m_detailRow[prodData.production_id], tr.nextSibling);	
		}
		else{
			tr.parentNode.appendChild(this.m_detailRow[prodData.production_id]);	
		}
		app.m_detailViews[detail_view_id].toDOM(this.m_detailRow[prodData.production_id]);
		$(app.m_detailViews[detail_view_id].getNode()).slideToggle(300);
	}
	else{
		var tr = DOMHelper.getParentByTagName(node,"TR");
		var detail_view_id = tr.nextSibling.getAttribute("detail_view_id");
		if(detail_view_id){
			window.getApp().m_detailViews[detail_view_id].delDOM();
		}
		this.getElement("grid").setRefreshInterval(this.m_gridRefreshInterval);				
		DOMHelper.delNode(this.m_detailRow[prodData.production_id]);			
	}
	
	this.m_details[prodData.production_id] = !this.m_details[prodData.production_id];
	$(node).toggleClass("rotate-90");	
}

OperatorList_View.prototype.showProdTooltip = function(toolTip,prodData,ev){
	var t_params = {
		"productionId":prodData.production_id
		,"productionDtStart":DateHelper.format(DateHelper.strtotime(prodData.production_dt_start),"H:i")
		,"productionDtEnd":DateHelper.format(DateHelper.strtotime(prodData.production_dt_end),"H:i")
		,"productionUser":prodData.production_user
		,"productionConcreteType":prodData.production_concrete_type_descr
	};

	var t = window.getApp().getTemplate("ElkonProdInf");
	t_params.bsCol = window.getBsCol();
	t_params.widthType = window.getWidthType();
	Mustache.parse(t);

	toolTip.popup(
		Mustache.render(t,t_params)
		,{"width":200,
		"title":"Производство Elkon",
		"className":"",
		"event":ev
		}
	);

}
