/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ProductionMaterialList_View(id,options){	

	ProductionMaterialList_View.superclass.constructor.call(this,id,options);

	var model = (options.models&&options.models.ProductionMaterialList_Model)? options.models.ProductionMaterialList_Model : new ProductionMaterialList_Model();
	var contr = new Production_Controller();
	
	var popup_menu = new PopUpMenu();
	var pagination = null,refresh_int = 0;
	
	if(!options.detailFilters){
		var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
		window.getApp().getConstantManager().get(constants);	
		refresh_int = constants.grid_refresh_interval.getValue()*1000;
		
		var pagClass = window.getApp().getPaginationClass();
		pagination = new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()});		
	}
	var self = this;
	this.addElement(new GridAjx(id+":grid",{
		"keyIds":["production_site_id","production_id","material_id","cement_silo_id"],
		"className":"table table-bordered table-responsive table-striped productionMaterialList",//+(!options.detailFilters? " table":""),
		"model":model,
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_production_material_list"),
		"editInline":true,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdDelete":false,
			"filters":null,
			"cmdAllCommands":options.detailFilters? false:true,
			"cmdSearch":options.detailFilters? false:true,
			"variantStorage":options.variantStorage
		}),		
		"popUpMenu":popup_menu,
		"onEventSetCellOptions":function(opts){
			if(opts.gridColumn.getId()=="quant_fact"){
				opts.className = "quant_editable";
				var v = opts.fields.quant_corrected.getValue();
				if(v){					
					var elkon_cor = opts.fields.elkon_correction_id.getValue();
					opts.attrs = opts.attrs || {};
					if(elkon_cor&&elkon_cor!="0"){
						opts.attrs.title = "Исправления Elkon №"+elkon_cor+" от "+DateHelper.format(opts.fields.correction_date_time_set.getValue(),"d/m/y H:i")+
							", "+opts.fields.correction_users_ref.getValue().getDescr();
						opts.className+= " factQuantCorrectedElkon";
					}
					else{
						opts.className+= " factQuantCorrected";	
						opts.attrs.title = "Ручное исправление:"+" от "+DateHelper.format(opts.fields.correction_date_time_set.getValue(),"d/m/y H:i")+
							", "+opts.fields.correction_users_ref.getValue().getDescr();
						
					}
				}
				opts.events = opts.event || {};
				opts.events.dblclick = (function(thisForm){
					return function(e){
						if(thisForm.m_editMode)return;
						var grid = thisForm.getElement("grid");
						var row = DOMHelper.getParentByTagName(e.target,"TR");
						if(row){							
							grid.setModelToCurrentRow(row);
							thisForm.onEditCons(grid.getModel().getFields());
						}
						if (e.preventDefault){
							e.preventDefault();
						}
						e.stopPropagation();
						return false;						
					}
				})(self);
			}
			else if(opts.gridColumn.getId()=="quant_dif"){
				if (opts.fields.dif_violation.getValue()){
					opts.className = "factQuantViolation";
				}
			}
		},
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						options.detailFilters? null:new GridCellHead(id+":grid:head:prodution_sites_ref",{
							"value":"Завод",							
							"columns":[
								new GridColumnRef({
									"field":model.getField("prodution_sites_ref"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlBindFieldId":"prodution_site_id",
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,options.detailFilters? null:new GridCellHead(id+":grid:head:prodution_id",{
							"value":"№ произв-ва",
							"columns":[
								new GridColumn({
									"field":model.getField("prodution_id"),
									"ctrlClass":ProductionSiteEdit,
									"ctrlBindFieldId":"prodution_id",
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,options.detailFilters? null:new GridCellHead(id+":grid:head:shipments_ref",{
							"value":"Отгрузка",
							"columns":[
								new GridColumnRef({
									"field":model.getField("shipments_ref"),
									"ctrlClass":null,
									"ctrlBindFieldId":"shipment_id",
									"ctrlOptions":{
										"labelCaption":""
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:materials_ref",{
							"value":"Материал",
							"colAttrs":{"width":"20px"},
							"columns":[
								new GridColumn({
									"field":model.getField("materials_ref"),
									"formatFunction":function(fields){
										var mat = fields.materials_ref.getValue();
										var res = !mat.isNull()? mat.getDescr():"";
										var sil = fields.cement_silos_ref.getValue();
										if(!sil.isNull()){
											res+= ", "+sil.getDescr();
										}
										return res;
									}
								})
							]
						})
						,new GridCellHead(id+":grid:head:quant_consuption",{
							"value":"Кол-во подбор",
							"colAttrs":{"align":"right","width":"10px"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant_consuption")
								})
							]
						})
						,new GridCellHead(id+":grid:head:quant_fact",{
							"value":"Кол-во факт",
							"colAttrs":{"align":"right","width":"10px"},
							"title":"Двойной клик для ручного исправления",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant_fact")
								})
							]
						})
						/*,new GridCellHead(id+":grid:head:quant_corrected",{
							"value":"Исправлено",
							"colAttrs":{"align":"right"},
							"title":"Ручное исправление",
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant_corrected")
								})
							]
						})
						*/
						,new GridCellHead(id+":grid:head:quant_dif",{
							"value":"Отклонение",
							"colAttrs":{"align":"right","width":"10px"},
							"columns":[
								new GridColumnFloat({
									"field":model.getField("quant_dif")
								})
							]
						})
						
					]
				})
			]
		}),
		"filters":options.detailFilters? options.detailFilters.ProductionMaterialList_Model:null,
		"pagination":pagination,				
		"autoRefresh":options.detailFilters? true:false,
		"refreshInterval":refresh_int,
		"rowSelect":false,
		"focus":true
	}));	
	
}
extend(ProductionMaterialList_View,ViewAjxList);


ProductionMaterialList_View.prototype.setCorrectionOnServer = function(newValues,fieldValues){
	var self = this;
	var pm = (new MaterialFactConsumptionCorretion_Controller()).getPublicMethod("operator_insert_correction");	
	pm.setFieldValue("production_site_id",fieldValues.production_site_id);
	pm.setFieldValue("material_id",fieldValues.material_id);
	pm.setFieldValue("cement_silo_id",fieldValues.cement_silo_id);
	pm.setFieldValue("production_id",fieldValues.production_id);
	//alert("newValues.quant="+newValues.quant+" fieldValues.material_quant="+fieldValues.material_quant);
	//return;
	pm.setFieldValue("cor_quant",newValues.quant - fieldValues.material_quant);
	pm.setFieldValue("comment_text",newValues.comment_text);
	pm.run({
		"ok":function(){
			window.showTempNote(fieldValues.material_descr+": откорректирован фактический расход по материалу",null,5000);				
			self.closeCorrection();
			self.getElement("grid").onRefresh();
		}
	})	
}

ProductionMaterialList_View.prototype.onEditCons = function(fields){

	this.m_editMode = true;
	var self = this;
	this.m_view = new EditJSON("CorrectQuant:cont",{
		"elements":[
			new EditFloat("CorrectQuant:cont:quant",{
				"labelCaption":"Количество:",
				"length":19,
				"precision":4,
				"focus":true,
				"value":fields.quant_fact.getValue(),
				"focus":true
			})
			,new EditText("CorrectQuant:cont:comment_text",{
				"labelCaption":"Комментарий:",
				"rows":3
			})
		]
	});
	this.m_form = new WindowFormModalBS("CorrectQuant",{
		"content":this.m_view,
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Корректировка фактического расхода "+fields.materials_ref.getValue().getDescr(),
		"onClickCancel":function(){
			self.closeCorrection();
		},
		"onClickOk":function(){
			var res = self.m_view.getValueJSON();
			/*if(!res||!res.comment_text||!res.comment_text.length){
				throw new Error("Не указан комментарий корректировки!");
			}*/
			self.setCorrectionOnServer(res,self.m_view.fieldValues);
		}
	});
	this.m_view.fieldValues = {
		"material_descr":fields.materials_ref.getValue().getDescr(),
		"production_site_id":fields.production_site_id.getValue(),
		"production_id":fields.production_id.getValue(),
		"material_id":fields.material_id.getValue(),
		"material_quant":fields.material_quant.getValue()
	}
	
	this.m_form.open();
	
}


ProductionMaterialList_View.prototype.closeCorrection = function(){
	this.m_view.delDOM()
	this.m_form.delDOM();
	delete this.m_view;
	delete this.m_form;			
	
	this.m_editMode = false;
}

