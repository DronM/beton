/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OperatorList_View(id,options){	

	OperatorList_View.superclass.constructor.call(this,id,options);

	var model = options.models.OperatorList_Model;
	this.m_totModel = options.models.OperatorTotals_Model;
	this.m_prodSiteModel = options.models.OperatorProductionSite_Model;
	var contr = new Shipment_Controller();
	
	var constants = {"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	var elements = [
		new GridCellHead(id+":grid:head:production_id",{
			"value":"№ произ-ва",
			"colAttrs":{"align":"center"},
			"columns":[
				new GridColumn({
					"field":model.getField("production_id"),
					"formatFunction":function(fields,gridCell){
						var col = gridCell.getGridColumn();
						col.tooltip = new ToolTip({
								"node":gridCell.getNode(),
								"wait":500,
								"onHover":function(ev){
									var tr = DOMHelper.getParentByTagName(ev.target,"TR");
									if(tr){
										var gr = self.getElement("grid")
										gr.setModelToCurrentRow(tr);
										var f = gr.getModel().getFields();
										var t_params = {};
										/*
										t_params.productionId = "123";
										t_params.productionDtStart = DateHelper.format(DateHelper.time(),"H:i");
										t_params.productionDtEnd = DateHelper.format(DateHelper.time(),"H:i");
										t_params.productionUser = "Миша";
										t_params.productionConcreteType = "M350";
										*/
										var t = window.getApp().getTemplate("ElkonProdInf");
										t_params.bsCol = window.getBsCol();
										t_params.widthType = window.getWidthType();
										Mustache.parse(t);
										
										t_params.productionId = f.production_id.getValue();
										t_params.productionDtStart = DateHelper.format(f.production_dt_start.getValue(),"H:i");
										t_params.productionDtEnd = DateHelper.format(f.production_dt_end.getValue(),"H:i");
										t_params.productionUser = f.production_user.getValue();
										t_params.productionConcreteType = f.production_concrete_types_ref.getValue().getDescr();
										
										
										col.tooltip.popup(
											Mustache.render(t,t_params)
											,{"width":200,
											"title":"Производство Elkon",
											"className":"",
											"event":ev
											}
										);
									}
								}
						});
						
						var res = fields.production_id.getValue();
						return res? res:"";
					},
					"master":true,
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
				new GridColumn({
					"field":model.getField("concrete_types_ref"),
					"formatFunction":function(fields,gridCell){
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
			"colSpan":"6"
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
	
	
	if(window.getApp().getServVar("role_id")!="operator"){
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
			if (!this.getModel().getFieldValue("shipped") && (col=="concrete_types_ref"||col=="quant") ){
				opts.className+= (opts.className.length? " ":"")+"operatorNotShipped";
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
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true,
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
		
		var new_data = this.m_model.getData().toString();
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
