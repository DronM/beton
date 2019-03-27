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
function Map_View(id,options){

	options = options || {};
	this.m_controller = new Vehicle_Controller();
	
	this.m_updateInterval = options.updateInterval || this.DEF_UPDATE_INTERVAL;
	
	this.m_paramVehicle = options.vehicle;
	this.m_paramValueFrom = options.valueFrom;
	this.m_paramValueTo = options.valueTo;
	
	var self = this;
	
	options.addElement = function(){
		var cl = "input-group "+window.getBsCol(2);
		
		this.addElement(new VehicleSelect(id+":vehicle",{
			"addAll":true,
			"value":options.vehicle,
			"onSelect":function(fields){
				self.onSelectVehicle(fields);
			},
			"editContClassName":cl
		}));	
		this.addElement(new ButtonCmd(id+":cmdFindVehicle",{
			"caption":"Найти ТС на карте",
			"onClick":function(){
				var veh = self.getElement("vehicle").getValue();
				if(veh){
					self.onSelectVehicleCont(veh.getKey());
				}
			}
		}));	
	
		this.addElement(new EditTime(id+":stop_duration",{
			"labelCaption":"Стоянки:",
			"value":"00:05",
			"editContClassName":cl
		}));	

		this.addElement(new EditPeriodDateShift(id+":period",{
			"valueFrom":this.m_paramValueFrom,
			"valueTo":this.m_paramValueTo
		}));

		
		this.addElement(new ButtonCmd(id+":cmdBuildReport",{
			"caption":"Сформировать",
			"onClick":function(){
				self.buildReport();
			}
		}));	
		this.addElement(new ButtonCmd(id+":cmdDeleteReport",{
			"caption":"Удалить",
			"onClick":function(){
				self.deleteReport();
			}
		}));	
		this.addElement(new ButtonCmd(id+":cmdGoToStart",{
			"caption":"В начало",
			"onClick":function(){
				self.goToStart();
			}
		}));	
		this.addElement(new ButtonCmd(id+":cmdGoToEnd",{
			"caption":"В конец",
			"onClick":function(){
				self.goToEnd();
			}
		}));	
	
	}
	
	Map_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Map_View,View);

/* Map */
Map_View.prototype.PAM_DIV_ID = "mapdiv";
Map_View.prototype.DEF_UPDATE_INTERVAL = 30000;

/* private members */

Map_View.prototype.m_layer;
Map_View.prototype.m_curVehicleId;
Map_View.prototype.m_interval;
Map_View.prototype.m_controller;
Map_View.prototype.m_updateInterval;
Map_View.prototype.m_zone;

/* protected*/


/* public methods */
Map_View.prototype.toDOM = function(parent){

	Map_View.superclass.toDOM.call(this,parent);

	this.m_map = new OpenLayers.Map("map",{"controls":[]});
	this.m_layer = new OpenLayers.Layer.OSM();		
	
	this.m_map.addLayer(this.m_layer);		
	
	var zoom_bar = new OpenLayers.Control.PanZoomBar();
	this.m_map.addControl(zoom_bar);	
	this.m_map.addControl(new OpenLayers.Control.LayerSwitcher());
	this.m_map.addControl(new OpenLayers.Control.ScaleLine());
	this.m_map.addControl(new OpenLayers.Control.Navigation());
	
	var constants = {"map_default_lon":null,"map_default_lat":null};
	window.getApp().getConstantManager().get(constants);
	
	this.m_vehicles = new VehicleLayer(this.m_map);	
	
	this.m_vehicles.moveMapToCoords(
		NMEAStrToDegree(constants.map_default_lon.getValue()),
		NMEAStrToDegree(constants.map_default_lat.getValue()),
		TRACK_CONSTANTS.INI_ZOOM
	);

	if(this.m_paramValueFrom&&this.m_paramValueTo){
		this.buildReport();
	}	
	else if(this.m_paramVehicle){
		this.onSelectVehicleCont(this.m_paramVehicle.getKey("id"));
	}
}

Map_View.prototype.onSelectVehicle = function(fields){
	this.onSelectVehicleCont(fields.id.getValue());
}

Map_View.prototype.onSelectVehicleCont = function(vehicleId){
	if (this.m_interval){
		clearInterval(this.m_interval);
		this.m_interval = null;
	}
	if (this.m_vehicles && this.m_curVehicleId!=undefined){
		this.m_vehicles.removeAllVehicles();
	}
	this.m_curVehicleId = vehicleId;
	if(vehicleId!=undefined)
		this.refreshCurPosition();
}

Map_View.prototype.findVehicle = function(){
	if (this.m_vehicles!=undefined){
		var veh_id = this.getElement("vehicle").getValue();
		if(veh_id)
			this.m_vehicles.flyToObjById(veh_id);
	}
}


Map_View.prototype.buildReport = function(){
	this.getTrack();
}

Map_View.prototype.deleteReport = function(){
	if (this.m_track!=undefined){
		this.m_track.removeLayer();
		delete this.m_track;
	}
	if (this.m_zone!=undefined){
		this.m_zone.removeLayer();
		delete this.m_zone;
	}
}

Map_View.prototype.goToStart = function(){
	if (this.m_track!=undefined){
		this.m_track.flyToStart();
	}
}

Map_View.prototype.goToEnd = function(){
	if (this.m_track!=undefined){
		this.m_track.flyToEnd();
	}
}

//******************************************************************
Map_View.prototype.refreshCurPosition = function(){
	var self = this;
	var pm;	
	if (this.m_curVehicleId==0){
		//all vehicles
		pm = this.m_controller.getPublicMethod("get_current_position_all");
	}
	else{
		pm = this.m_controller.getPublicMethod("get_current_position");
		pm.setFieldValue("id",this.m_curVehicleId)
	}
	
	pm.run({
		"ok":function(resp){
			self.onGetPosData(resp);
		}
	});
}

Map_View.prototype.getModelRow = function(model){
	var row = {};
	for (var f_id in model.m_fields){
		row[f_id] = model.m_fields[f_id].getValue();
	}
	return row;		
}

Map_View.prototype.onGetPosData = function(resp){
	var model = resp.getModel("get_current_position");
	
	var id,marker;
	while (model.getNextRow()){
		//all fields
		marker = new MapCarMarker(this.getModelRow(model));
		marker.image = TRACK_CONSTANTS.VEH_IMG;
		marker.imageScale = 0.8;
		if (!id){
			id = marker.id;
		}
		this.m_vehicles.removeVehicle(id);
		this.m_vehicles.addVehicle(marker,null,true,false);
	}
	//zones
	this.addZones(resp);
	
	if (id && !this.m_interval){
		this.m_vehicles.setCurrentObj(id,TRACK_CONSTANTS.FOUND_ZOOM);
		var self = this;
		this.m_interval = setInterval(
			function(){
				self.refreshCurPosition();
			},
			self.m_updateInterval
			);
	}
}
Map_View.prototype.addZones = function(resp){
	if (this.m_zone==undefined){
		this.m_zone = new GeoZones(this.m_map,"Гео зоны");
	}
	this.m_zone.deleteZone();
	
	model = resp.getModel("zones");
	var points;
	while (model.getNextRow()){
		//base
		var zone_str = model.getFieldValue("base");
		if (zone_str){			
			zone_str = zone_str.split(" ").join(",");
			var zone_points = zone_str.split(",");	
			zone_points.splice(zone_points.length-2,2);//remove last point		
			this.m_zone.drawZoneOnCoords(zone_points);
		}		
		//dest
		var zone_str = model.getFieldValue("dest");
		if (zone_str){
			zone_str = zone_str.split(" ").join(",");
			var zone_points = zone_str.split(",");	
			zone_points.splice(zone_points.length-2,2);//remove last point				
			this.m_zone.drawZoneOnCoords(zone_points);
		}
	}
}

Map_View.prototype.getTrack = function(){	
	var sel_veh_id = this.getElement("vehicle").getValue()? this.getElement("vehicle").getValue().getKey():0;
	if (sel_veh_id==0){
		return;
	}	
	if (this.m_track==undefined){
		this.m_track = new TrackLayer(this.m_map);
	}
	var self = this;	
			
	var pm = this.m_controller.getPublicMethod("get_track");
	pm.setFieldValue("id",sel_veh_id);
	pm.setFieldValue("dt_from",this.getElement("period").getControlFrom().getValue());
	pm.setFieldValue("dt_to",this.getElement("period").getControlTo().getValue());
	pm.setFieldValue("stop_dur",this.getElement("stop_duration").getValue());
	window.setGlobalWait(true);
	pm.run({
		"ok":function(resp){
			self.onGetTrackData(resp);
		},
		"all":function(){
			window.setGlobalWait(false);
		}
	})
}

Map_View.prototype.onGetTrackData = function(resp){
	var model = resp.getModel("track_data");
	
	var markers = [];
	var marker,ind;
	var x_max=0,x_min=9999,y_max=0,y_min=9999;
	ind = 1;
	while (model.getNextRow()){
		if (model.getFieldValue("speed")==0){
			marker = new MapStopMarker(this.getModelRow(model));
		}
		else{
			marker = new MapMoveMarker(this.getModelRow(model));
		}
		marker.ordNumber = ind;
		marker.sensorEngPresent = true;
		markers.push(marker);
		x_max=(x_max<marker.lon)? marker.lon:x_max;
		x_min=(x_min>marker.lon)? marker.lon:x_min;
		y_max=(y_max<marker.lat)? marker.lat:y_max;
		y_min=(y_min>marker.lat)? marker.lat:y_min;
		
		ind++;
	}
	this.m_track.addMarkers(markers);
	
	//zones	
	this.addZones(resp);
	
	this.m_track.zoomToCenter(x_max,x_min,y_max,y_min);
	//this.m_track.flyToStart();
}

