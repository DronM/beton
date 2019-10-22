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
	
	MaterialFactConsumptionRolledList_View.superclass.constructor.call(this,id,options);
	
	var auto_refresh = options.models.MaterialFactConsumptionRolledList_Model? false:true;
	var model = options.models.MaterialFactConsumptionRolledList_Model? options.models.MaterialFactConsumptionRolledList_Model : new MaterialFactConsumptionRolledList_Model();
	var contr = new MaterialFactConsumption_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var period_ctrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
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
	var grid = new GridAjx(id+":grid",{
		"keyIds":["date_time","production_site_id"],
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
		},
		
		"head":new GridHead(id+":grid:head",{
				"elements":this.getGridHead(options.models.MaterialFactConsumptionMaterialList_Model? options.models.MaterialFactConsumptionMaterialList_Model:null,model)
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":auto_refresh,
		"refreshInterval":null,//constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	});	

	this.m_orig_onGetData = grid.onGetData
	var self = this;
	grid.onGetData = function(resp){
		if(resp){
			var h = this.getHead();
			var m = resp.getModel("MaterialFactConsumptionRolledList_Model");
			h.delDOM();
			h.m_elements = self.getGridHead(
				resp.getModel("MaterialFactConsumptionMaterialList_Model"),
				m
			);
			h.toDOM(this.m_node);			
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

MaterialFactConsumptionRolledList_View.prototype.getGridHead = function(headModel,model){
	var id = this.getId();
	
	var row0_elem = [
		new GridCellHead(id+":grid:head:row0:date_time",{
			"value":"Дата",
			"colAttrs":{"align":"center"},
			"attrs":{"rowspan":"2"},
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("date_time"),
					"ctrlClass":EditDateTime,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					},
					"master":true,
					"detailViewClass":MaterialFactConsumptionList_View,
					"detailViewOptions":{
						"detailFilters":{
							"MaterialFactConsumptionList_Model":[
								{
								"masterFieldId":"date_time",
								"field":"date_time",
								"sign":"e",
								"val":"0"
								},
								{
								"masterFieldId":"production_site_id",
								"field":"production_site_id",
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
			"attrs":{"rowspan":"2"},
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
	
		,new GridCellHead(id+":grid:head:row0:upload_users_ref",{
			"value":"Кто загрузил",
			"attrs":{"rowspan":"2"},
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
			"attrs":{"rowspan":"2"},
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
		,new GridCellHead(id+":grid:head:row0:concrete_types_ref",{
			"value":"Марка",
			"attrs":{"rowspan":"2"},
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
			"attrs":{"rowspan":"2"},
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
			"attrs":{"rowspan":"2"},
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
			"attrs":{"rowspan":"2"},
			"columns":[
				new GridColumn({
					"field":model.getField("shipments_inf"),
					"ctrlClass":EditString,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":false
					}
				})
			]
		})
		,new GridCellHead(id+":grid:head:row0:concrete_quant",{
			"value":"Объем",
			"colAttrs":{"align":"right"},
			"attrs":{"rowspan":"2"},
			"columns":[
				new GridColumn({
					"field":model.getField("concrete_quant"),
					"ctrlClass":EditFloat,
					"ctrlOptions":{
						"precision":4
					}																		
				})
			]
		})
	];
	
	var row1_elem = [];
	
	if(headModel){	
		headModel.reset();
		var m_descr;
		var m_ind = 0;
		var mat_col_ids = {};
		while(headModel.getNextRow()){
			m_descr = headModel.getFieldValue("raw_material_production_descr");			
			
			var col_q_id = "m_"+m_ind+"_q";
			   var col_q_r_id = "m_"+m_ind+"_q_r";				
			mat_col_ids[m_descr] = m_ind;
			m_ind++;
			
			var f_q = new FieldFloat(col_q_id,{"precision":4,"length":19});
			var f_q_r = new FieldFloat(col_q_r_id,{"precision":4,"length":19}); 
			model.addField(f_q);
			model.addField(f_q_r);
			
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
			row1_elem.push(
				new GridCellHead(id+":grid:head:row1:"+col_q_id,{
					"value":"Кол-во",
					"colAttrs":{"align":"right"},
					"columns":[
						new GridColumn({
							"field":f_q
						})
					]
				})		
			);	
			row1_elem.push(
				new GridCellHead(id+":grid:head:row1:m_"+col_q_r_id,{
					"value":"Затреб.",
					"colAttrs":{"align":"right"},
					"columns":[
						new GridColumn({
							"field":f_q_r
						})
					]
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
					
						model.setFieldValue(col_q_id,materials[j].quant);
						model.setFieldValue(col_q_r_id,materials[j].quant_req);									
						break;
					}
				}
			}
			model.recUpdate();
		}
		model.reset();
	}	
	return [new GridRow(id+":grid:head:row0",{"elements":row0_elem}),new GridRow(id+":grid:head:row1",{"elements":row1_elem})];

}
