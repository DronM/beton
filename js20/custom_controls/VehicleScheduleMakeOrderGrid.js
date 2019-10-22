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
function VehicleScheduleMakeOrderGrid(id,options){
	options = options || {};	
	
	var model = options.model;	
	CommonHelper.merge(options,{
		"model":model,
		"className":"table-bordered table-responsive table-make_order veh_schedule_grid",		
		"attrs":{"style":"width:100%;"},
		"readPublicMethod":(new VehicleSchedule_Controller()).getPublicMethod("get_current_veh_list"),
		"editInline":false,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":false,
			"cmdSearch":false,
			"cmdInsert":false,//new GridCmdInsert(id+":grid:cmd:insert",{"showCmdControl":false})
			"cmdAllCommands":false,
			"cmdExport":false,
			"cmdPrint":false,
			"cmdEdit":false,
			"cmdRefresh":false,
			"cmdDelete":false,
			"cmdCopy":false,
			"filters":null,
			"variantStorage":null,
			"addCustomCommandsAfter":function(commands){
				commands.push(new VehicleScheduleGridCmdSetFree(id+":grid:cmd:setFree",{"showCmdControl":false}));
				commands.push(new VehicleScheduleGridCmdSetOut(id+":grid:cmd:setOut",{"showCmdControl":false}));
				commands.push(new VehicleScheduleGridCmdShowPosition(id+":grid:cmd:showPos",{"showCmdControl":false}));
			}
		}),
		"popUpMenu":new PopUpMenu(),
		"onEventSetCellOptions":function(opts){
			if(opts.gridColumn.getId()=="vehicles_ref"){
				opts.className = opts.className||"";
				var m = this.getModel();
				if(m.getFieldValue("no_tracker")){
					opts.title="Нет оборудования мониторинга";
					opts.className+=(opts.className.length? " ":"")+"no_tracker";
				}
				else if(m.getFieldValue("tracker_no_data")){
					opts.title="Нет сигнала";
					opts.className+=(opts.className.length? " ":"")+"tracker_no_data";
				}
			}				
		},
		"onEventSetRowOptions":function(opts){
			opts.className = opts.className||"";
			var m = this.getModel();
			var veh_state = m.getFieldValue("state");
				
			opts.className+=(opts.className.length? " ":"")+"veh_in_make_list";
			if (m.getFieldValue("is_late")){
				opts.className+=(opts.className.length? " ":"")+"veh_late";
			}
			else{
				opts.className+=(opts.className.length? " ":"")+ "veh_"+veh_state;
			}
			if (m.getFieldValue("is_late_at_dest")){
				opts.className+=(opts.className.length? " ":"")+"veh_late_at_dest";
			}

			if (veh_state=="shift"){
				opts.className+=(opts.className.length? " ":"")+"veh_shift";
			}
		},
		
		"head":new GridHead(id+":veh_schedule_grid:head",{
			"elements":[
				new GridRow(id+"veh_schedule_grid:head:row0",{
					"elements":[
						new GridCellHead(id+":veh_schedule_grid:head:vehicles_ref",{
							"value":"Номер",
							"columns":[
								new GridColumnRef({
									"field":model.getField("vehicles_ref"),
									"master":true,
									"detailViewClass":VehicleRun_View,
									"detailViewOptions":{
										"detailFilters":{
											"VehicleRun_Model":[
												{
												"masterFieldId":"id",
												"field":"schedule_id",
												"sign":"e",
												"val":"0"
												}	
											]
										}													
									}										
								})
							]								
						})
						,new GridCellHead(id+":veh_schedule_grid:head:drivers_ref",{
							"value":"Водитель",
							"columns":[
								new GridColumn({
									"field":model.getField("drivers_ref"),
									"formatFunction":function(fields,cell){
										var dr_name = window.getApp().formatCell(fields.drivers_ref,cell,VehicleScheduleMakeOrderList_View.prototype.COL_DRIVER_LEN);
										var tel = fields.driver_tel.getValue();
										var ext = window.getApp().getServVar("tel_ext");
										if(!tel || !tel.length || !ext || !ext.length){
											return dr_name;
										}											
										else{
											var cell_n = cell.getNode();
											var c_tag = document.createElement("I");
											c_tag.className = "fa fa-phone";
											c_tag.title="Набрать номер водителя";
											c_tag.setAttribute("tel",tel);
											EventHelper.add(c_tag,"click",function(e){
												e = EventHelper.fixMouseEvent(e);
												console.log(e.target)
												window.getApp().makeCall(e.target.getAttribute("tel"));
											});
											cell_n.appendChild(c_tag);
											var c_tag = document.createElement("SPAN");
											c_tag.textContent = " "+dr_name;
											cell_n.appendChild(c_tag);
											
											return "";
										}
									}
								})
							]
						})
						,new GridCellHead(id+":veh_schedule_grid:head:owner",{
							"value":"Владелец",
							"columns":[
								new GridColumn({
									"field":model.getField("owner"),
									"formatFunction":function(fields,cell){
										return window.getApp().formatCell(fields.owner,cell,VehicleScheduleMakeOrderList_View.prototype.COL_OWNER_LEN);
									}
								})
							]
						})
						,new GridCellHead(id+":veh_schedule_grid:head:load_capacity",{
							"value":"Гр",
							"title":"Грузоподъемность",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({"field":model.getField("load_capacity")})
							]
						})
						,new GridCellHead(id+":veh_schedule_grid:head:state",{
							"value":"Сост.",
							"columns":[
								new EnumGridColumn_vehicle_states({"field":model.getField("state")})
							]
						})
						,new GridCellHead(id+":veh_schedule_grid:head:inf_on_return",{
							"value":"Вр.",
							"title":"Время",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({"field":model.getField("inf_on_return")})
							]
						})
						,new GridCellHead(id+":veh_schedule_grid:head:runs",{
							"value":"Р-сы",
							"title":"Количество рейсов",
							"colAttrs":{"align":"center"},
							"columns":[
								new GridColumn({"field":model.getField("runs")})
							]
						})
						
					]
				})
			]
		}),
		"pagination":null,
		"autoRefresh":false,
		"refreshInterval":null,
		"rowSelect":true,
		"focus":false
	});	
	
	VehicleScheduleMakeOrderGrid.superclass.constructor.call(this,id,options);
}

extend(VehicleScheduleMakeOrderGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

