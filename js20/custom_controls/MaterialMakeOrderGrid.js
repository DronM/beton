/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends Grid
 * @requires core/extend.js
 * @requires controls/.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MaterialMakeOrderGrid(id,options){
	options = options || {};	
	
	var model = options.model;
	
	this.m_refresh = options.refresh;
	
	var self = this;
	
	CommonHelper.merge(options,
		{
			"attrs":{"style":"width:100%;"},
			"keyIds":["material_id"],
			"readPublicMethod":null,
			"editInline":false,
			"editWinClass":null,
			"commands":null,
			"popUpMenu":null,
			"onEventSetCellOptions":function(opts){				
				if (opts.gridColumn.getId()=="quant_morn_fact_cur_balance" ){
					var rows = this.getModel().getFieldValue("balance_corrected_data");
					if(rows && rows.length){
						opts.className = opts.className||"";
						opts.className+= ((opts.className=="")? "":" ")+"factQuantCorrected";
					}
				}
			},
			
			"head":new GridHead(id+":head",{
				"elements":[
					new GridRow(id+":head:row0",{
						"elements":[
							new GridCellHead(id+":head:material_descr",{
								"value":"Материал",
								"columns":[
									new GridColumn({"field":model.getField("material_descr")})
								]
							})
							,new GridCellHead(id+":head:quant_ordered",{
								"value":"Заявл.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_ordered"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":head:quant_morn_fact_cur_balance",{
								"value":"Ост.утро",
								"colAttrs":{
									"align":"right",
									"class":"quant_editable",
									"title":"Двойной клик для корректировки остатка"
								},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_morn_fact_cur_balance"),
										"precision":3,
										"cellOptions":{
											"events":{
												"dblclick":function(ev){
													self.setModelToCurrentRow(DOMHelper.getParentByTagName(ev.target,"TR"));
													self.correctQuant(self.getModel().getFields());
												}
											}										
										},
										"formatFunction":function(fields,gridCell){
											var col = gridCell.getGridColumn();
											col.tooltip = new ToolTip({
													"node":gridCell.getNode(),
													"wait":500,
													"onHover":function(ev){
														var tr = DOMHelper.getParentByTagName(ev.target,"TR");
														if(tr){
															self.setModelToCurrentRow(tr);
															var f = self.getModel().getFields();
															var t_params = {
																"rows":f.balance_corrected_data.getValue()
															};
															if(t_params.rows && t_params.rows.length){
																for(var i=0;i<t_params.rows.length;i++){
																	t_params.rows[i].user_descr = t_params.rows[i].users_ref.m_descr;
																	t_params.rows[i].date_time_descr = DateHelper.format(DateHelper.strtotime(t_params.rows[i].date_time),"d/m/y H:i");
																}
																console.log(t_params.rows)
																
																var t = window.getApp().getTemplate("MaterialFactBalanceCorretionInf");
																t_params.bsCol = window.getBsCol();
																t_params.widthType = window.getWidthType();
																Mustache.parse(t);
																
																col.tooltip.popup(
																	Mustache.render(t,t_params)
																	,{"width":200,
																	"title":"Коорректировки остатка по материалу",
																	"className":"",
																	"event":ev
																	}
																);
																
															}
														}
													}
											});
										
											return CommonHelper.numberFormat(fields.quant_morn_fact_cur_balance.getValue(),3,"."," ");
										}
									})
								],
							})
							
							,new GridCellHead(id+":head:quant_procured",{
								"value":"Приход",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_procured"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":head:quant_fact_balance",{
								"value":"Ост.тек.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_fact_balance"),
										"precision":3
									})
								]
							})
							,new GridCellHead(id+":head:quant_morn_next_balance",{
								"value":"Ост.веч.",
								"colAttrs":{"align":"right"},
								"columns":[
									new GridColumnFloat({
										"field":model.getField("quant_morn_next_balance"),
										"precision":3
									})
								]
							})
						]
					})
				]
			}),
			"pagination":null,
			"autoRefresh":false,
			"refreshInterval":null,
			"rowSelect":false,
			"focus":false,
			"navigate":false,
			"navigateClick":false
		}
	);
	
	MaterialMakeOrderGrid.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(MaterialMakeOrderGrid,Grid);

/* Constants */


/* private members */

/* protected*/


/* public methods */
MaterialMakeOrderGrid.prototype.setCorrectionOnServer = function(newValues,matDifStore,fieldValues){
	var self = this;
	var pm = (new MaterialFactBalanceCorretion_Controller()).getPublicMethod("insert");
	pm.setFieldValue("material_id",fieldValues.material_id);
	pm.setFieldValue("comment_text",newValues.comment_text);
	pm.setFieldValue("required_balance_quant",newValues.quant);
	if(matDifStore){
		pm.setFieldValue("production_site_id",newValues.production_sites_ref.getKey("id"));
	}
	else{
		pm.resetFieldValue("production_site_id");
	}
	pm.run({
		"ok":function(){
			window.showTempNote(fieldValues.material_descr+": откорректирован остаток на утро",null,5000);				
			self.closeCorrection();
			self.m_refresh();
		}
	})	
}

MaterialMakeOrderGrid.prototype.correctQuantCont = function(fields,matDifStore){
	var self = this;
	var elements = [];
	if(matDifStore){
		elements.push(
			new ProductionSiteEdit("CorrectQuant:cont:production_sites_ref",{
				"labelCaption":"Завод:",
				"required":"true",
				"focus":true
			})
		);
	}
	elements.push(
		new EditFloat("CorrectQuant:cont:quant",{
			"labelCaption":"Количество:",
			"length":19,
			"precision":4,
			"focus":!matDifStore
		})
	);
	elements.push(
		new EditText("CorrectQuant:cont:comment_text",{
			"labelCaption":"Комментарий:",
			"rows":3
		})
	);
	
	this.m_view = new EditJSON("CorrectQuant:cont",{
		"elements":elements
	});
	this.m_form = new WindowFormModalBS("CorrectQuant",{
		"content":this.m_view,
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Корректировка количества "+fields.material_descr.getValue(),
		"onClickCancel":function(){
			self.closeCorrection();
		},
		"onClickOk":(function(matDifStore,self){
			return function(){
				var res = self.m_view.getValueJSON();
				if(!res||!res.production_sites_ref||res.production_sites_ref.isNull()){
					throw new Error("Не указан завод!");
				}
				self.setCorrectionOnServer(res,matDifStore,self.m_view.fieldValues);
			}
		})(matDifStore,self)
	});
	this.m_view.fieldValues = {
		"material_id":fields.material_id.getValue(),
		"material_descr":fields.material_descr.getValue()
	}
	
	this.m_form.open();
}

MaterialMakeOrderGrid.prototype.correctQuant = function(fields){
	
	var mat_id = fields.material_id.getValue();
	var app = window.getApp();
	app.m_materialDifStore = app.m_materialDifStore || {};
	if(app.m_materialDifStore["id"+mat_id]==undefined){
		//get attribute
		var self = this;
		var pm = (new RawMaterial_Controller()).getPublicMethod("get_object");
		pm.setFieldValue("id",mat_id);
		pm.run({
			"ok":(function(fields,matId){
				return function(resp){
					var m = resp.getModel("RawMaterial_Model");
					if(m.getNextRow()){
						var dif_store = m.getFieldValue("dif_store");
						window.getApp().m_materialDifStore["id"+matId] = dif_store;
						self.correctQuantCont(fields,dif_store);
					}
				}
			})(fields,mat_id)
		});
	}
	else{
		this.correctQuantCont(fields,app.m_materialDifStore["id"+mat_id]);
	}	
}

MaterialMakeOrderGrid.prototype.closeCorrection = function(){
	this.m_view.delDOM()
	this.m_form.delDOM();
	delete this.m_view;
	delete this.m_form;			
}

