/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OperatorList_View(id,options){	

	OperatorList_View.superclass.constructor.call(this,id,options);

	var model = options.models.OperatorList_Model;
	this.m_totInitModel = options.models.OperatorTotals_Model;
	var contr = new Shipment_Controller();
	
	var constants = {"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	var elements = [
		new GridCellHead(id+":grid:head:date_time",{
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
					"field":model.getField("quant")
				})
			]
		})
		,new GridCellHead(id+":grid:head:concrete_types_ref",{
			"value":"Марка",
			"columns":[
				new GridColumnRef({
					"field":model.getField("concrete_types_ref")
				})
			]
		})
		,new GridCellHead(id+":grid:head:vehicles_ref",{
			"value":"ТС",
			"columns":[
				new GridColumnRef({
					"field":model.getField("vehicles_ref")
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
			"gridColumn":new GridColumnFloat({"id":"tot_quant"})
		})						
	];
	
	
	if(window.getApp().getServVar("role_id")!="operator"){
		elements.push(
			new GridCellHead(id+":grid:head:ship_norm_min",{
				"value":"Норма отгр.",
				"attrs":{"align":"right"},
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
				"attrs":{"align":"right"},
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
				"attrs":{"align":"right"},
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
		var tot_m;
		if(resp){		
			tot_m = resp.getModel("OperatorTotals_Model");
		}
		else{
			tot_m = self.m_totInitModel;
		}
		if(tot_m.getNextRow()){
			var q_shipped = parseFloat(tot_m.getFieldValue("quant_shipped"));
			var q_ordered = parseFloat(tot_m.getFieldValue("quant_ordered"));
			document.getElementById("totShipped").value = q_shipped.toFixed(2);
			document.getElementById("totOrdered").value = q_ordered.toFixed(2);
			document.getElementById("totBalance").value = (q_ordered-q_shipped).toFixed(2);
		}
		self.m_gridOnGetData.call(self.getElement("grid"),resp);
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
