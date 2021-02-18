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
	
	/*
	 * При открытии параметры передаются либо через options либо через location при ручном открытии, иои открытии по ссылке
	 * т.о. открыть можно простой ссылкой
	*/
	this.m_paramVehicle = options.vehicle;
	this.m_paramTrackerId = options.tracker_id;
	this.m_paramValueFrom = options.valueFrom;
	this.m_paramValueTo = options.valueTo;
	stop_duration = "00:05";
	
	var par_p = window.location.href.indexOf("?");
	if (par_p){
		var href_par = window.location.href.substring(par_p+1).split('&');
		var key_v;
		for(var i=0;i<href_par.length;i++){
			key_v = href_par[i].split('=');
			if(key_v&&key_v.length&&key_v.length==2){
				if(key_v[0]=='id'){
					this.m_paramVehicle = new RefType({"keys":{"id":key_v[1]},"descr":""});
				}
				else if(key_v[0]=='tracker_id'){
					this.m_paramTrackerId = key_v[1];
				}
				else if(key_v[0]=='from'||key_v[0]=='dt_from'){
					this.m_paramValueFrom = DateHelper.strtotime(key_v[1]);
				}
				else if(key_v[0]=='to'||key_v[0]=='dt_to'){
					this.m_paramValueTo = DateHelper.strtotime(key_v[1]);
				}					
				else if(key_v[0]=='stop_duration'){
					stop_duration = key_v[1];
				}					
			}
		}
	}

	this.m_paramZone_Model = (options.models&&options.models.ZoneList_Model)? options.models.ZoneList_Model:null;
	this.m_paramCurrentPosition_Model = (options.models&&options.models.VehicleLastPos_Model)? options.models.VehicleLastPos_Model:null;
	this.m_paramTrack_Model = (options.models&&options.models.TrackData_Model)? options.models.TrackData_Model:null; 
	this.m_paramRoute_Model = (options.models&&options.models.Route_Model)? options.models.Route_Model:null; 
	
	var self = this;
	
	options.addElement = function(){
		var cl = "input-group "+window.getBsCol(2);
		
		this.addElement(new VehicleSelect(id+":vehicle",{
			"addAll":true,
			"value":this.m_paramVehicle,
			"onSelect":function(fields){
				self.onSelectVehicle(fields.id.getValue(),fields.tracker_id.getValue());
			},
			"editContClassName":cl
		}));	
		this.addElement(new ButtonCmd(id+":cmdFindVehicle",{
			"caption":"Найти ТС на карте",
			"onClick":function(){
				var veh = self.getElement("vehicle").getValue();
				if(veh){
					var id = veh.getKey();
					if(self.m_vehicles.m_vehicles[id]){
						self.m_vehicles.setCurrentObj(id,TRACK_CONSTANTS.FOUND_ZOOM);
					}
					else{
						//no vehile on map
						self.refreshCurPosition(function(){
							self.m_vehicles.setCurrentObj(self.m_curTrackerId);
						});
					}
				}
			}
		}));	
	
		this.addElement(new EditTime(id+":stop_duration",{
			"labelCaption":"Стоянки:",
			"value":stop_duration,
			"editContClassName":cl
		}));	

		this.addElement(new EditPeriodDateShift(id+":period",{
			"valueFrom":this.m_paramValueFrom,
			"valueTo":this.m_paramValueTo
		}));

		
		this.addElement(new ButtonCmd(id+":cmdBuildReport",{
			"caption":"Сформировать",
			"onClick":function(){
				self.getTrack();
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

		this.addElement(new EditCheckBox(id+":cmdFollowVehicle",{
			"labelCaption":"Перемещать карту за ТС:"
			,"value":true
			,"events":{
				"change":function(e){
					self.setFollowVehicle(this.getValue());
				}
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
	
	this.m_vehicles = new VehicleLayer(this.m_map);	

	//No parameters - default coords
	var constants = {"map_default_lon":null,"map_default_lat":null};
	window.getApp().getConstantManager().get(constants);
	
	this.m_vehicles.moveMapToCoords(
		NMEAStrToDegree(constants.map_default_lon.getValue()),
		NMEAStrToDegree(constants.map_default_lat.getValue()),
		TRACK_CONSTANTS.INI_ZOOM
	);
console.log("this.m_paramRoute_Model=")	
console.log(this.m_paramRoute_Model)
	if(this.m_paramVehicle && (this.m_paramCurrentPosition_Model||this.m_paramTrack_Model||this.m_paramZone_Model||this.m_paramRoute_Model)){
		//open init data
		if(!this.m_paramTrackerId){
			//could be missing - get from list
			this.m_paramTrackerId = this.getElement("vehicle").getModelRow().tracker_id.getValue();
		}
		
		this.m_curVehicleId = this.m_paramVehicle.getKey();
		this.m_curTrackerId = this.m_paramTrackerId;
		
		//zones
		if(this.m_paramZone_Model){
			this.addZones(this.m_paramZone_Model);
		}
		//track
		if(this.m_paramTrack_Model){			
			if (this.m_track==undefined){
				this.m_track = new TrackLayer(this.m_map);
			}
		
			if(this.addTrackData(this.m_paramTrack_Model)<=1){
				this.moveToDefaultCoords();
			}
		}
		
		//position
		if(this.m_paramCurrentPosition_Model){
			this.addPosData(this.m_paramCurrentPosition_Model);
		}	
		
		//hypothatical route
		if(this.m_paramRoute_Model && this.m_paramRoute_Model.getNextRow()){
			var f = this.m_paramRoute_Model.getField("route");
			var vv = f.getValue();
			this.addGuessedRoute(vv);	
		}
		
		if (this.getElement("cmdFollowVehicle").getValue()){		
			this.setFollowVehicle(true);		
		}
		
		this.m_vehicles.setCurrentObj(this.m_curVehicleId,TRACK_CONSTANTS.FOUND_ZOOM);
			
	}
	else if(this.m_paramVehicle && this.m_paramTrackerId && !this.m_paramCurrentPosition_Model ){
		//no init model - fetch
		this.onSelectVehicle(this.m_paramVehicle.getKey(),this.m_paramTrackerId);
	}
	else{
		this.moveToDefaultCoords();
	}
}

Map_View.prototype.moveToDefaultCoords = function(){
	//No parameters - default coords
	var constants = {"map_default_lon":null,"map_default_lat":null};
	window.getApp().getConstantManager().get(constants);
	
	this.m_vehicles.moveMapToCoords(
		NMEAStrToDegree(constants.map_default_lon.getValue()),
		NMEAStrToDegree(constants.map_default_lat.getValue()),
		TRACK_CONSTANTS.INI_ZOOM
	);
}

Map_View.prototype.onSelectVehicle = function(vehicleId,trackerId){
console.log("Map_View.prototype.onSelectVehicle")
	this.setFollowVehicle(false);

	if (this.m_vehicles && this.m_curVehicleId!=undefined){
		this.m_vehicles.removeAllVehicles();
	}
	
	this.m_curVehicleId = vehicleId;
	this.m_curTrackerId = trackerId;
	
	//get initial postion one/all
	this.refreshCurPosition();	
	if (this.getElement("cmdFollowVehicle").getValue()){		
		this.setFollowVehicle(true);		
	}	
}

Map_View.prototype.setFollowVehicle = function(v){
	if (v){
		var self = this;
		
		if(window.getApp().getAppSrv()){
			//event server
			console.log("setFollowVehicle to "+this.m_curTrackerId)
			this.subscribeToSrvEvents(
				[
					{"id":"Vehicle.position."+this.m_curTrackerId}
				]
				,function(json){
					self.updateVehiclePosition({
						'id':self.m_curVehicleId
						,'pos_data':json.params
					});
					self.m_vehicles.setCurrentObj(self.m_curTrackerId);//,TRACK_CONSTANTS.FOUND_ZOOM
					//self.m_track.zoomToCenter(json.params.lon,json.params.lon,json.params.lat,json.params.lat);
					/*
					self.m_vehicles.moveMapToCoords(
						json.params.lon
						,json.params.lat
						//,TRACK_CONSTANTS.FOUND_ZOOM - same zoom as before
					);
					*/
				}
			);
		}
		else{
			//constant query on timer
			this.m_interval = setInterval(
				function(){
					self.refreshCurPosition(function(){
						self.m_vehicles.setCurrentObj(self.m_curTrackerId);
					});
				},
				self.m_updateInterval
			);
		}				
	}
	else if(window.getApp().getAppSrv()){
		this.unsubscribeFromSrvEvents();	
	}
	else if (this.m_interval){
		clearInterval(this.m_interval);
		this.m_interval = null;
	}		
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
/**
 * fetches current veh or all vehicles position
 * server method
 */
Map_View.prototype.refreshCurPosition = function(callBack){

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
			self.onGetPosData(resp,callBack);
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

/**
 * plate,heading_str,period_str,period,lon_str,lat_str,speed
 *	vehicle_current_pos_all
 */
Map_View.prototype.updateVehiclePosition = function(rowStruc){
	//all fields marker.id=Vehicle ID
	var marker = new MapCarMarker(rowStruc);
//console.log("Map_View.prototype.updateVehiclePosition ID="+marker.id)	

	marker.image = TRACK_CONSTANTS.VEH_IMG;
	marker.imageScale = 0.8;
	this.m_vehicles.removeVehicle(marker.id);
	this.m_vehicles.addVehicle(marker,null,true,false);

	if (this.m_guessedRouteLayer && this.m_guessedRouteLayer.m_geom){
		var pt = this.m_vehicles.getMapPoint(marker.pos_data.lon,marker.pos_data.lat);
		var d = pt.distanceTo(this.m_guessedRouteLayer.m_geom);
		console.log(d)
		//OpenLayers.Geometry.distanceTo(geometry,opts)
	}
}

/**
 * vehicle markers to map
 */
Map_View.prototype.addPosData = function(model){
	while (model.getNextRow()){
		//all fields
		var r = this.getModelRow(model);
		r.pos_data = CommonHelper.unserialize(r.pos_data);
		this.updateVehiclePosition(r);
	}
}

/**
 * VehicleLastPos_Model
 * ZoneList_Model
 * Route_Model
 */
Map_View.prototype.onGetPosData = function(resp,callBack){
	var m;
	
	m = resp.getModel("VehicleLastPos_Model");
	if(m)
		this.addPosData(m);
	
	//zones
	m = resp.getModel("ZoneList_Model");
	if(m)
		this.addZones(m);	

	//hypothatical route
	m = resp.getModel("Route_Model");	
	if(m && m.getNextRow()){
		this.addGuessedRoute(m.getFieldValue("route"));	
	}
	
	if(callBack)callBack();
}

/**
 */
Map_View.prototype.addGuessedRoute = function(routeGeom){
	var points = decodeLine(routeGeom.replace(/\\\\/g, "\\"));//ext function				
	if (this.m_guessedRouteLayer!=undefined){
		this.m_map.removeLayer(this.m_guessedRouteLayer); 
		delete this.m_guessedRouteLayer;
	}
	this.m_guessedRouteLayer = new OpenLayers.Layer.Vector("Предполагаемый маршрут");
	
	var map_features = [];
	
	this.m_zone.addLineFromPoints(map_features,points,{
		strokeColor: "#0074FF",
		strokeWidth: 4,
		pointRadius: 6,
		pointerEvents: "visiblePainted"
	});

	this.m_guessedRouteLayer.m_geom = map_features.length? map_features[0].geometry:null;
	this.m_guessedRouteLayer.addFeatures(map_features);
	this.m_map.addLayer(this.m_guessedRouteLayer); 
	
	window.showTempNote("Проложен маршрут",null,5000);

}

/*
 * all zones frommodel to Map
 */
Map_View.prototype.addZones = function(model){
	if (this.m_zone==undefined){
		this.m_zone = new GeoZones(this.m_map,"Гео зоны");
	}
	this.m_zone.deleteZone();
	
	var points;
	while (model.getNextRow()){
		//base
		var zone_str = model.getFieldValue("base_zone");
		if (zone_str){			
			zone_str = zone_str.split(" ").join(",");
			var zone_points = zone_str.split(",");	
			zone_points.splice(zone_points.length-2,2);//remove last point		
			this.m_zone.drawZoneOnCoords(zone_points);
		}		
		//dest
		var zone_str = model.fieldExists("dest_zone")? model.getFieldValue("dest_zone"):null;
		if (zone_str){
			zone_str = zone_str.split(" ").join(",");
			var zone_points = zone_str.split(",");	
			zone_points.splice(zone_points.length-2,2);//remove last point				
			this.m_zone.drawZoneOnCoords(zone_points);
		}
	}
}

/**
 * report server method
 */
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

/**
 * markers to map
 */
Map_View.prototype.addTrackData = function(model){
	
	var markers = [];
	var marker,ind,r;
	var x_max=0,x_min=9999,y_max=0,y_min=9999;
	ind = 1;
	while (model.getNextRow()){
		r = this.getModelRow(model);
		r.pos_data = CommonHelper.unserialize(r.pos_data);
		
		if (r.pos_data.speed==0){
			marker = new MapStopMarker(r);
		}
		else{
			marker = new MapMoveMarker(r);
		}
		marker.ordNumber = ind;
		marker.sensorEngPresent = true;
				
		console.log("marker=",marker)
		markers.push(marker);
		x_max=(x_max<marker.pos_data.lon)? marker.pos_data.lon:x_max;
		x_min=(x_min>marker.pos_data.lon)? marker.pos_data.lon:x_min;
		y_max=(y_max<marker.pos_data.lat)? marker.pos_data.lat:y_max;
		y_min=(y_min>marker.pos_data.lat)? marker.pos_data.lat:y_min;
		
		ind++;
	}
	this.m_track.addMarkers(markers);
	
	this.m_track.zoomToCenter(x_max,x_min,y_max,y_min);
	//this.m_track.flyToStart();
	return ind;
}

Map_View.prototype.onGetTrackData = function(resp){
	var m;
	
	//zones	
	m = resp.getModel("ZoneList_Model");
	if(m)
		this.addZones(m);
	
	//track
	m = resp.getModel("TrackData_Model");
	if(m)
		this.addTrackData(m);
	
}

