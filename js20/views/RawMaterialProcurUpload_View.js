/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
*/
/* constructor */
function RawMaterialProcurUpload_View(id,options){
	options = options || {};

	var model = options.models.RawMaterialProcurUpload_Model;
	var contr = new RawMaterialProcurUpload_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	
	var is_admin = (window.getApp().getServVar("role_id")=="owner");
	
	options.addElement = function(){
		
		var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
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
		};
		
		var pagClass = window.getApp().getPaginationClass();
		var grid = new GridAjx(id+":grid",{
			"model":model,
			"controller":contr,
			"editInline":false,
			"editWinClass":VehicleScheduleDialog_Form,
			"insertViewOptions":function(){
				return {"schedule_date":self.getElement("schedule_date").getDateFrom()};
			},
			"commands":new GridCmdContainerAjx(id+":grid:cmd",{
				"cmdInsert":is_admin,
				"cmdEdit":is_admin,
				"cmdCopy":false,
				"cmdFilter":true,
				"cmdSearch":false,
				"filters":filters,
				"variantStorage":null
			}),
			"popUpMenu":null,
			"head":new GridHead(id+"-grid:head",{
				"elements":[
					new GridRow(id+":grid:head:row0",{
						"elements":[
							new GridCellHead(id+":grid:head:schedule_date",{
								"value":"Дата",
								"columns":[
									new GridColumnDate({
										"field":model.getField("schedule_date")
									})
								]
							})
							,new GridCellHead(id+":grid:head:doc_count",{
								"value":"Кол-во документов",
								"columns":[
									new GridColumn({
										"field":model.getField("doc_count")
									})
								]
							})
						
						]
					})
				]
			}),
			"pagination":new pagClass(id+"_page",
				{"countPerPage":constants.doc_per_page_count.getValue()}),		
			"autoRefresh":false,
			"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
			"rowSelect":false,
			"focus":true
		});	
		this.addElement(grid);
		
		per_select.setGrid(grid);
	}
	
	RawMaterialProcurUpload_View.superclass.constructor.call(this,id,options);
	
}
extend(RawMaterialProcurUpload_View,ViewAjxList);
