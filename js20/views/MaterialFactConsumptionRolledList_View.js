/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MaterialFactConsumptionRolledList_View(id,options){
	options = options || {};
	options.models = options.models || {};
	
	this.HEAD_TITLE = "Фактический расход материалов (свернуто)";
	
	MaterialFactConsumptionRolledList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.MaterialFactConsumptionRolledList_Model? false:true;
	var model = options.models.MaterialFactConsumptionRolledList_Model? options.models.MaterialFactConsumptionRolledList_Model : new MaterialFactConsumptionRolledList_Model();
	var contr = new MaterialFactConsumption_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	var self = this;
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
		,"production_site":{
			"binding":new CommandBinding({
				"control":new ProductionSiteEdit(id+":filter-ctrl-production_site",{
					"contClassName":"form-group-filter",
					"labelCaption":"Завод:"
				}),
				"field":new FieldInt("production_site_id")}),
			"sign":"e"		
		}
		,"concrete_type":{
			"binding":new CommandBinding({
				"control":new ConcreteTypeEdit(id+":filter-ctrl-concrete_type",{
					"contClassName":"form-group-filter",
					"labelCaption":"Марка:"
				}),
				"field":new FieldInt("concrete_type_id")}),
			"sign":"e"		
		}
		
	}	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	var grid_struc = this.getGridStruc(options.models.MaterialFactConsumptionMaterialList_Model? options.models.MaterialFactConsumptionMaterialList_Model:null,model);
	var grid = new GridAjx(id+":grid",{
		"keyIds":["production_site_id","production_id"],
		"model":model,
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_rolled_list"),
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":true,
			"cmdEdit":false,
			"cmdInsert":false,
			"cmdDelete":false,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"popUpMenu":popup_menu,
		"onEventSetCellOptions":function(opts){
			if(!this.m_matchCheckColList){
				this.m_matchCheckColList = ["vehicles_ref","concrete_types_ref"];
			}
			var col = opts.gridColumn.getId();
			if(CommonHelper.inArray(col,this.m_matchCheckColList)!=-1){
				opts.className = opts.className||"";
				var m = this.getModel();
				if(m.getField(col).isNull()){
					opts.title="Соответствие не определено!";
					opts.className+=(opts.className.length? " ":"")+"prouction_upload_no_match";
				}
			}
			if(col=="production_id" && this.getModel().getFieldValue("material_tolerance_violated")){
				opts.className = opts.className||"";
				opts.className+= (opts.className.length? " ":"")+"factQuantViolation";
			}
			else if(col=="shipments_ref"){
				//&& this.getModel().getFieldValue("shipments_ref").isNull()
				opts.events = opts.events || {
					"dblclick":(function(productionKey,dateTime){
						return function(e){
							self.selectShipment(productionKey,dateTime);
						}
					})(this.getModel().getFieldValue("production_key"),this.getModel().getFieldValue("date_time"))
				}
			}
			else if(col=="vehicles_ref"){
				opts.events = opts.events || {
					"dblclick":(function(productionSiteId,productionId){
						return function(e){
							self.selectVehicle(productionSiteId,productionId);
						}
					})(this.getModel().getFieldValue("production_site_id"),this.getModel().getFieldValue("production_id"))
				}
			}
			
		},
		
		"head":new GridHead(id+":grid:head",{
				"elements":grid_struc.head
		}),
		"foot":new GridFoot(id+":grid:foot",{
			"autoCalc":true,			
			"elements":grid_struc.foot
		}),		
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":auto_refresh,
		"refreshInterval":null,//constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	

	this.m_orig_onGetData = grid.onGetData
	grid.onGetData = function(resp){
		if(resp){
			var h = this.getHead();
			this.m_model = resp.getModel("MaterialFactConsumptionRolledList_Model");
			h.delDOM();
			var grid_struc = self.getGridStruc(
				resp.getModel("MaterialFactConsumptionMaterialList_Model"),
				this.m_model
			);			
			h.m_elements = grid_struc.head; 
			h.toDOM(this.m_node);
			
			var f = this.getFoot();			
			f.delDOM();
			f.m_elements = grid_struc.foot; 
			f.toDOM(this.m_node);
			
		}
		self.m_orig_onGetData.call(this);
	}

	this.addElement(grid);
}
//ViewObjectAjx,ViewAjxList
extend(MaterialFactConsumptionRolledList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

MaterialFactConsumptionRolledList_View.prototype.getGridStruc = function(headModel,model){
	var id = this.getId();
	
	var row0_elem = [
		new GridCellHead(id+":grid:head:row0:date_time",{
			"value":"Дата",
			"colAttrs":{"align":"center"},
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("date_time"),
					"ctrlClass":EditDateTime,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
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
			],
			"sortable":true,
			"sort":"desc"																					
		})
		,new GridCellHead(id+":grid:head:row0:production_sites_ref",{
			"value":"Завод",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("production_sites_ref"),
					"ctrlClass":ProductionSiteEdit,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					},
					"ctrlBindFieldId":"production_site_id"
				})
			]
		})
		,new GridCellHead(id+":grid:head:row0:production_id",{
			"value":"№ пр-ва",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumn({
					"field":model.getField("production_id"),
					"ctrlClass":EditNum
				})
			]
		})
		
		/*
		,new GridCellHead(id+":grid:head:row0:upload_users_ref",{
			"value":"Кто загрузил",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("upload_users_ref"),
					"ctrlClass":UserEditRef,
					"form":User_Form,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					},
					"ctrlBindFieldId":"upload_user_id"
				})
			]
		})
		,new GridCellHead(id+":grid:head:row0:upload_date_time",{
			"value":"Дата загрузки",
			"colAttrs":{"align":"center"},
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("upload_date_time"),
					"ctrlClass":EditDateTime,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					}									
				})
			]
		})
		*/
		,new GridCellHead(id+":grid:head:row0:concrete_types_ref",{
			"value":"Марка",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("concrete_types_ref"),
					"ctrlClass":ConcreteTypeEdit,
					"ctrlOptions":{
						"labelCaption":""
					},
					"ctrlBindFieldId":"concrete_type_id",
					"formatFunction":function(fields){
						return fields.concrete_types_ref.isNull()? fields.concrete_type_production_descr.getValue():fields.concrete_types_ref.getValue().getDescr();
					}									
				})
			]
		})
		,new GridCellHead(id+":grid:head:row0:vehicles_ref",{
			"value":"ТС",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("vehicles_ref"),
					"form":VehicleDialog_Form,
					"ctrlClass":VehicleEdit,
					"ctrlOptions":{
						"labelCaption":""
					},
					"ctrlBindFieldId":"vehicle_id",
					"formatFunction":function(fields){
						return fields.vehicles_ref.isNull()? fields.vehicle_production_descr.getValue():fields.vehicles_ref.getValue().getDescr();
					}									
				})
			]
		})
		,new GridCellHead(id+":grid:head:row0:orders_ref",{
			"value":"Заявка",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("orders_ref"),
					"ctrlClass":OrderEdit,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					},
					"form":OrderDialog_Form
				})
			]
		})
		,new GridCellHead(id+":grid:head:row0:shipments_inf",{
			"value":"Отгрузка",
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumnRef({
					"field":model.getField("shipments_ref"),
					"ctrlClass":ShipmentEdit,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					},
					"form":ShipmentDialog_Form
				})				
			]
		})
		,new GridCellHead(id+":grid:head:row0:concrete_quant",{
			"value":"Объем",
			"colAttrs":{"align":"right"},
			"attrs":{"rowspan":"3"},
			"columns":[
				new GridColumn({
					"field":model.getField("concrete_quant"),
					"ctrlClass":EditFloat,
					"precision":2,
					"ctrlOptions":{
						"precision":2
					}																		
				})
			]
		})
	];
	
	var foot0_elem	= [
		new GridCell(id+":grid:foot:sp2",{
			"colSpan":"7"
		})
		,new GridCellFoot(id+":grid:foot:concrete_quant",{
			"attrs":{"align":"right"},
			"calcOper":"sum",
			"calcFieldId":"concrete_quant",
			"gridColumn":new GridColumn({"id":"tot_concrete_quant"})
		})						
														
	];
	
	var row1_elem = [];
	var row2_elem = [];
	
	if(headModel){	
	
		headModel.reset();
		var mat_ref;
		var cur_mat_id;
		var prev_mat_id = 0;
		var prev_mat_descr;
		var col_span_ar;		
		var row0_id = 0,row1_id = 0;
		var mat_ind = 0;
		var add_rows = function(){
			if(col_span_ar && col_span_ar.length){				
				//previous
				var attrs0 = {};
				var attrs1 = {};
				if(!prev_mat_id){
					attrs0["class"] = "production_upload_no_match";
					attrs1["class"] = "production_upload_no_match";
				}								
				
				if(col_span_ar.length>1){
					attrs0.colspan = col_span_ar.length * 3;//Расход факт/Подбор завод/Подбор отгузка
					row0_elem.push(
						new GridCellHead(id+":grid:head:row0:mat_"+row0_id,{
							"name":"mat_"+row0_id,
							"value":prev_mat_descr,
							"colAttrs":{"align":"center"},
							"attrs":attrs0
						})
					);						
					row0_id++;
										
					attrs1.colspan = "3";
					var attrs1_tmp;
					for(var i=0;i<col_span_ar.length;i++){
						mat_ind++;
						attrs1_tmp = CommonHelper.clone(attrs1);
						attrs1_tmp["class"] = attrs1_tmp["class"] || "";
						attrs1_tmp["class"]+= ( (attrs1_tmp["class"]=="")? "":" ")+( (mat_ind%2)? "mat_odd":"mat_even");
						
						row1_elem.push(
							new GridCellHead(id+":grid:head:row1:mat_"+row1_id,{
								"name":"mat_"+row1_id,
								"value":col_span_ar[i],
								"colAttrs":{"align":"center"},
								"attrs":attrs1_tmp
							})
						);												
						row1_id++;					
					}
				}
				else{	
					mat_ind++;						
					attrs0["class"] =attrs0["class"] || "";
					attrs0["class"]+= ( (attrs0["class"]=="")? "":" ")+( (mat_ind%2)? "mat_odd":"mat_even");
							
					attrs0.rowspan = "2";
					attrs0.colspan = "3";
					row0_elem.push(
						new GridCellHead(id+":grid:head:row0:mat_"+row0_id,{
							"name":"mat_"+row0_id,
							"value":prev_mat_descr,
							"colAttrs":{"align":"center"},
							"attrs":attrs0
						})
					);
					row0_id++;						
				}
			}
		
		}
		
		while(headModel.getNextRow()){
			mat_ref = CommonHelper.unserialize(headModel.getFieldValue("raw_materials_ref"));
			cur_mat_id = (mat_ref && !mat_ref.isNull())? mat_ref.getKey("id"):undefined;
			if(
			(cur_mat_id && cur_mat_id!=prev_mat_id)
			||!cur_mat_id
			){
				add_rows();
				prev_mat_id = cur_mat_id;
				prev_mat_descr = cur_mat_id? mat_ref.getDescr():headModel.getFieldValue("raw_material_production_descr");
				col_span_ar = [];//init
			}
			col_span_ar.push(headModel.getFieldValue("raw_material_production_descr"));
		}
		add_rows();
		
		headModel.reset();
		var m_descr;
		var m_ind = 0;
		var mat_col_ids = {};
		while(headModel.getNextRow()){
			m_descr = headModel.getFieldValue("raw_material_production_descr");
			
			var col_q_id = "m_"+m_ind+"_q";
			var col_q_r_id = "m_"+m_ind+"_q_r";
			var col_q_sh_id = "m_"+m_ind+"_q_sh";
			mat_col_ids[m_descr] = m_ind;
			m_ind++;
			
			var f_q = new FieldFloat(col_q_id,{"precision":4,"length":19});
			var f_q_r = new FieldFloat(col_q_r_id,{"precision":4,"length":19});
			var f_q_sh = new FieldFloat(col_q_sh_id,{"precision":4,"length":19});			  
			model.addField(f_q);
			model.addField(f_q_r);
			model.addField(f_q_sh);
			/*
			var attrs = {"colspan":"2"};
			if(CommonHelper.unserialize(headModel.getFieldValue("raw_materials_ref")).isNull()){
				attrs["class"] = "production_upload_no_match";
			}
			
			row0_elem.push(
				new GridCellHead(id+":grid:head:m_"+m_descr,{
					"value":m_descr,
					"colAttrs":{"align":"center"},
					"attrs":attrs
				})
			);
			*/
			row2_elem.push(
				new GridCellHead(id+":grid:head:row2:"+col_q_id,{
					"value":"Расход факт",
					"attrs":{"class":((m_ind%2)? "mat_odd":"mat_even")},
					"colAttrs":{"align":"right","class":((m_ind%2)? "mat_odd":"mat_even")},
					"columns":[
						new GridColumnFloat({
							"field":f_q
							,"precision":"4"
							,"ctrlOptions":{
								"precision":"4"
							}
						})
					]
				})		
			);	
			row2_elem.push(
				new GridCellHead(id+":grid:head:row2:m_"+col_q_r_id,{
					"value":"Подбор завод",
					"attrs":{"class":((m_ind%2)? "mat_odd":"mat_even")},
					"colAttrs":{"align":"right","class":((m_ind%2)? "mat_odd":"mat_even")},
					"columns":[
						new GridColumnFloat({
							"field":f_q_r
							,"precision":"4"
							,"ctrlOptions":{
								"precision":"4"
							}							
						})
					]
				})		
			);
			row2_elem.push(
				new GridCellHead(id+":grid:head:row2:m_"+col_q_sh_id,{
					"value":"Подбор отгузка",
					"attrs":{"class":((m_ind%2)? "mat_odd":"mat_even")},
					"colAttrs":{"align":"right","class":((m_ind%2)? "mat_odd":"mat_even")},
					"columns":[
						new GridColumnFloat({
							"field":f_q_sh
							,"precision":"4"
							,"ctrlOptions":{
								"precision":"4"
							}							
						})
					]
				})		
			);
			//*********************
			
			foot0_elem.push(
				new GridCellFoot(id+":grid:foot:row0:m_"+col_q_id,{
					"attrs":{"align":"right","class":((m_ind%2)? "mat_odd":"mat_even")},
					"calcOper":"sum",
					"calcFieldId":col_q_id,
					"gridColumn":new GridColumnFloat({"id":"tot_m_"+col_q_id,"precision":"4"})
				})									
			);
			foot0_elem.push(
				new GridCellFoot(id+":grid:foot:row0:m_"+col_q_r_id,{
					"attrs":{"align":"right","class":((m_ind%2)? "mat_odd":"mat_even")},
					"calcOper":"sum",
					"calcFieldId":col_q_r_id,
					"gridColumn":new GridColumnFloat({"id":"tot_m_"+col_q_r_id,"precision":"4"})
				})									
			);
			foot0_elem.push(
				new GridCellFoot(id+":grid:foot:row0:m_"+col_q_sh_id,{
					"attrs":{"align":"right","class":((m_ind%2)? "mat_odd":"mat_even")},
					"calcOper":"sum",
					"calcFieldId":col_q_sh_id,
					"gridColumn":new GridColumnFloat({"id":"tot_m_"+col_q_sh_id,"precision":"4"})
				})									
			);
			
		}
		
		var materials;
		var m_descr;
		while(model.getNextRow()){				
			materials = model.getFieldValue("materials");
			headModel.reset();
			while(headModel.getNextRow()){
				m_descr = headModel.getFieldValue("raw_material_production_descr");					
				for(var j=0;j<materials.length;j++){
					if(materials[j].production_descr==m_descr){					
						var col_q_id = "m_"+mat_col_ids[m_descr]+"_q";
						var col_q_r_id = "m_"+mat_col_ids[m_descr]+"_q_r";
						var col_q_sh_id = "m_"+mat_col_ids[m_descr]+"_q_sh";
					
						model.setFieldValue(col_q_id,materials[j].quant);
						model.setFieldValue(col_q_r_id,materials[j].quant_req);
						model.setFieldValue(col_q_sh_id,materials[j].quant_shipped);
						break;
					}
				}
			}
			model.recUpdate();
		}
		model.reset();
	}
		
	
	return {
		"head":[
			new GridRow(id+":grid:head:row0",{"elements":row0_elem}),
			new GridRow(id+":grid:head:row1",{"elements":row1_elem}),
			new GridRow(id+":grid:head:row2",{"elements":row2_elem})
		]
		,"foot":[
			new GridRow(id+":grid:foot:row0",{
				"elements":foot0_elem
			})		
		]
	};

}

MaterialFactConsumptionRolledList_View.prototype.selectShipment = function(productionKey,dateTime){
	var self = this;
	this.m_view = new ShipmentList_View("ShipmentList:cont",{
		"forSelect":true,
		"date_time":dateTime,
		"onSelect":(function(productionKey){
			return function(row){
				self.closeShipmentSelect(productionKey,row.id.getValue());
			}
		})(productionKey)
	});
	this.m_form = new WindowFormModalBS("ShipmentList",{
		"content":this.m_view,
		"dialogWidth":"80%",
		"cmdCancel":true,
		"cmdOk":false,
		"contentHead":"Выберите отгрузку",
		"onClickCancel":function(){
			self.closeShipmentSelect();
		}
	});
	
	this.m_form.open();
	
}

MaterialFactConsumptionRolledList_View.prototype.selectVehicle = function(productionSiteId,productionId){
	var self = this;
	this.m_view = new View("Vehicle:cont",{
		"elements":[
			new VehicleEdit("Vehicle:cont:vehicles_ref",{
				"labelCaption":"ТС:",
				"focus":true
			})
		]
	});
	this.m_form = new WindowFormModalBS("Vehicle",{
		"content":this.m_view,
		"dialogWidth":"30%",
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Выберите ТС",
		"onClickCancel":function(){
			self.closeVehicleSelect();
		},
		"onClickOk":(function(productionSiteId,productionId){
			return function(){	
				var v = self.m_view.getElement("vehicles_ref").getValue();
				if(!v||v.isNull()){
					throw Error("Не выбрано ТС!");
				}
				self.closeVehicleSelect(productionSiteId,productionId,v.getKey());
			}
		})(productionSiteId,productionId)
	});
	
	this.m_form.open();
	
}

MaterialFactConsumptionRolledList_View.prototype.closeSelect = function(){
	if(this.m_view){
		this.m_view.delDOM()	
		delete this.m_view;
	}
	if(this.m_form){
		this.m_form.delDOM();	
		delete this.m_form;
	}	
}

MaterialFactConsumptionRolledList_View.prototype.closeVehicleSelect = function(productionSiteId,productionId,vehicleId){
	this.closeSelect();
	if(productionSiteId&&productionId&&vehicleId){
		var pm = (new ProductionVehicleCorrection_Controller()).getPublicMethod("insert");
		var self = this;
		pm.setFieldValue("production_site_id",productionSiteId);
		pm.setFieldValue("production_id",productionId);
		pm.setFieldValue("vehicle_id",vehicleId);
		window.setGlobalWait(true);
		pm.run({
			"ok":function(){
				if(self.getElement("grid")){
					self.getElement("grid").onRefresh(function(){
						window.setGlobalWait(false);
						window.showTempNote("К производству привязано новое ТС",null,5000);
					});
				}				
			}
			,"fail":function(resp,errCode,errStr){				
				window.setGlobalWait(false);
				throw Error(errStr);
			}
		});
	}
}

MaterialFactConsumptionRolledList_View.prototype.closeShipmentSelect = function(productionKey,shipmentId){
	this.closeSelect();
	if(productionKey&&shipmentId){
		var pm = (new Production_Controller()).getPublicMethod("update");
		var self = this;
		pm.setFieldValue("old_id",productionKey);
		pm.setFieldValue("shipment_id",shipmentId);
		window.setGlobalWait(true);
		pm.run({
			"ok":function(){
				
				if(self.getElement("grid")){
					self.getElement("grid").onRefresh(function(){
						window.setGlobalWait(false);
						window.showTempNote("К производству привязана отгрузка",null,5000);
					});					
				}				
			}
			,"fail":function(resp,errCode,errStr){				
				window.setGlobalWait(false);
				throw Error(errStr);
			}
		});
	}
}

