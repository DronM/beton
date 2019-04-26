/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleScheduleMakeOrderList_View(id,options){	

	var model = options.models.VehicleScheduleMakeOrderList_Model;
	var contr = new VehicleSchedule_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var self = this;
	
	options.addElement = function(){
		var popup_menu = new PopUpMenu();
		var pagClass = window.getApp().getPaginationClass();
		var grid = new GridAjx(id+":grid",{
			"className":"table table-bordered table-responsive",
			"model":model,
			"readPublicMethod":contr.getPublicMethod("get_current_veh_list"),
			"editInline":false,
			"editWinClass":null,
			"commands":new GridCmdContainerAjx(id+":grid:cmd",{
				"cmdInsert":false,
				"cmdEdit":false,
				"cmdFilter":false,
				"cmdSearch":false,
				"filters":null,
				"variantStorage":null
			}),
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
				
				//opts.title = "Кликните для отображения местоположения ТС карте";
				
				/*opts.events = opts.events || {};
				opts.events.click = function(e){
					if(e.target.tagName=="TD"){
						self.showVehCurrentPosition(CommonHelper.unserialize(this.getAttr("keys")).id);
					}
				}*/
			},			
			"popUpMenu":popup_menu,
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
							,new GridCellHead(id+":grid:head:vehicles_ref",{
								"value":"ТС",
								"columns":[
									new GridColumnRef({
										"field":model.getField("vehicles_ref"),
										"ctrlClass":VehicleEdit,
										"searchOptions":{
											"field":new FieldInt("vehicle_id"),
											"searchType":"on_match"
										}									
									})
								]
							})
							,new GridCellHead(id+":grid:head:drivers_ref",{
								"value":"Водитель",
								"columns":[
									new GridColumn({
										"field":model.getField("drivers_ref"),
										"ctrlClass":DriverEditRef,
										"searchOptions":{
											"field":new FieldInt("driver_id"),
											"searchType":"on_match"
										},
										"formatFunction":function(fields,cell){
											return window.getApp().formatCell(fields.drivers_ref,cell,self.COL_DRIVER_LEN);
										}																		
									})
								]
							})
							,new GridCellHead(id+":grid:head:owner",{
								"value":"Владелец ТС",
								"columns":[
									new GridColumn({
										"field":model.getField("owner"),
										"formatFunction":function(fields,cell){
											return window.getApp().formatCell(fields.owner,cell,self.COL_OWNER_LEN);
										}																												
									})
								]
							})
							,new GridCellHead(id+":grid:head:load_capacity",{
								"value":"Груз.",
								"columns":[
									new GridColumn({
										"field":model.getField("load_capacity")
									})
								]
							})
							,new GridCellHead(id+":grid:head:state",{
								"value":"Сост.",
								"columns":[
									new EnumGridColumn_vehicle_states({
										"field":model.getField("state")
									})
								]
							})
						]
					})
				]
			}),
			"selectedRowClass":"order_current_row",
			"pagination":new pagClass(id+"_page",
				{"countPerPage":constants.doc_per_page_count.getValue()}),		
			"autoRefresh":false,
			"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
			"rowSelect":false,
			"focus":true
		});	
		this.addElement(grid);
		
	}
	
	VehicleScheduleMakeOrderList_View.superclass.constructor.call(this,id,options);
}
extend(VehicleScheduleMakeOrderList_View,ViewAjxList);

VehicleScheduleMakeOrderList_View.prototype.COL_DRIVER_LEN = 8;
VehicleScheduleMakeOrderList_View.prototype.COL_OWNER_LEN = 8;
VehicleScheduleMakeOrderList_View.prototype.COL_DEST_LEN = 8;

