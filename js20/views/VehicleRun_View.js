/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function VehicleRun_View(id,options){
	options = options || {};	
	
	VehicleRun_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models&&options.models.VehicleRun_Model)? options.models.VehicleRun_Model: new VehicleRun_Model();
	var contr = new VehicleSchedule_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var role = window.getApp().getServVar("role_id");
	var self = this;
		
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"className":options.detailFilters? OrderMakeList_View.prototype.TABLE_CLASS:null,
		"keyIds":["veh_id"],
		"model":model,
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod("get_vehicle_runs"),
		"editInline":null,
		"editWinClass":null,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdSearch":false,
			"cmdFilter":false,
			"cmdAllCommands":false,
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdDelete":false/*,
			БУДЕТ ВМЕСТО onEventSetRowOptions НО там появляется popUpMenu от главной таблицы
			"addCustomCommandsAfter":function(commands){
				commands.push(new VehicleRunGridCmdShowMap(id+":grid:cmd:showMap",{"showCmdControl":false}));
			}		
			*/	
		}),
		"onEventSetRowOptions":function(opts){
			opts.attrs = opts.attrs||{};
			opts.attrs.style = opts.attrs.style||"";
			opts.attrs.style+= "cursor:pointer;";
			opts.title = "Кликните для отображения маршрута на карте";
			opts.events = opts.events || {};
			opts.events.click = function(e){
				if(e.target.tagName=="TD"){
					self.showVehCurrentPosition(CommonHelper.unserialize(this.getAttr("keys")).veh_id);
				}
			}
		},
		"popUpMenu":null,
		"filters":(options.detailFilters&&options.detailFilters.VehicleRun_Model)? options.detailFilters.VehicleRun_Model:null,
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:st_free_start",{
							"value":"База",
							"columns":[
								new GridColumnDate({
									"field":model.getField("st_free_start"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:st_assigned",{
							"value":"Назн.",
							"columns":[
								new GridColumnDate({
									"field":model.getField("st_assigned"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:st_shipped",{
							"value":"Отгр.",
							"columns":[
								new GridColumnDate({
									"field":model.getField("st_shipped"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:st_at_dest",{
							"value":"Прибыл",
							"columns":[
								new GridColumnDate({
									"field":model.getField("st_at_dest"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:st_left_for_base",{
							"value":"Убыл",
							"columns":[
								new GridColumnDate({
									"field":model.getField("st_left_for_base"),
									"dateFormat":"H:i"
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
						
						,new GridCellHead(id+":grid:head:st_free_end",{
							"value":"База",
							"columns":[
								new GridColumnDate({
									"field":model.getField("st_free_end"),
									"dateFormat":"H:i"
								})
							]
						})
						,new GridCellHead(id+":grid:head:run_time",{
							"value":"Время",
							"columns":[
								new GridColumnDate({
									"field":model.getField("run_time"),
									"dateFormat":"H:i"
								})
							]
						})
						
					]
				})
			]
		}),
		"pagination":options.detailFilters? null : new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()}),		
		"autoRefresh":options.detailFilters? true : false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":options.detailFilters? false : true
	}));		
}
//ViewObjectAjx,ViewAjxList
extend(VehicleRun_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

VehicleRun_View.prototype.showVehCurrentPosition = function(vehicleId){
	var self = this;
	var dt_from,dt_to;
	var m = this.getElement("grid").getModel();
	m.reset();
	while(m.getNextRow()){
		if(m.getFieldValue("veh_id")==vehicleId){
			dt_from = m.getFieldValue("st_free_start");
			dt_to = m.getFieldValue("st_free_end");
			break;
		}
	}
	
	var win_w = $( window ).width();
	var h = $( window ).height()-20;//win_w/3*2;
	var left = win_w/3;
	var w = win_w/3*2;//left - 20;
	
	this.m_mapForm = new WindowForm({
		"id":"MapForm",
		"height":h,
		"width":w,
		"left":left,
		"top":10,
		"URLParams":"t=Map&v=Child",
		"name":"Map",
		"params":{
			"editViewOptions":{
				"vehicle":new RefType({"keys":{"id":vehicleId}}),
				"valueFrom":dt_from,
				"valueTo":dt_to
			}
		},
		"onClose":function(){
			self.m_mapForm.close();
			delete self.m_mapForm;			
		}
	});
	this.m_mapForm.open();

}

