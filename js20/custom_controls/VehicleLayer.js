/* Copyright (c) 2010 
	Andrey Mikhalevich, Katren ltd.
*/
/*
*/

/**
 * @requires main.js
 * @requires OpenLayers.js 
*/

/*
	Base class for holding layers and objects
*/
function VehicleLayer(map,options){
	options = options || {};
	VehicleLayer.superclass.constructor.call(this,map,this.LAYER_DESCR);	
	
	this.m_vehicles = [];
	
	this.CURRENT_THEME = options.theme || TRACK_CONSTANTS.DEF_THEME;
}
extend(VehicleLayer,ObjMapLayer);//base class

VehicleLayer.prototype.LAYER_DESCR = "Объекты мониторинга";
VehicleLayer.prototype.OBJ_POINTER_SCALE = 1;
//constants
VehicleLayer.prototype.TAIL_MARKER_CURSOR = 'pointer';
VehicleLayer.prototype.TAIL_MARKER_OPACITY = 1;
VehicleLayer.prototype.TAIL_MARKER_POINT_RADIUS = 12;
VehicleLayer.prototype.CAR_MARKER_CURSOR = 'pointer';
VehicleLayer.prototype.CAR_MARKER_OPACITY = 0.7;
VehicleLayer.prototype.CAR_CUR_MARKER_OPACITY = 1;
VehicleLayer.prototype.CAR_MARKER_POINT_RADIUS = 12;

/*
	Makes the map fly to the specified object
*/
VehicleLayer.prototype.flyToObjById = function(id,zoom){
	if (this.m_vehicles[id]==undefined){
		throw new Error('Object with id '+id+' not found!');
	}
//console.log("VehicleLayer.prototype.flyToObjById ID="+id+" moving map to LON="+this.m_vehicles[id].head.pos_data.lon+" LAT="+this.m_vehicles[id].head.pos_data.lat+" ZOOM="+zoom || this.map.getZoom())	
	this.moveMapToCoords(
		this.m_vehicles[id].head.pos_data.lon,
		this.m_vehicles[id].head.pos_data.lat,
		zoom || this.map.getZoom()
	);
	/*
	var lonLat = this.getLonLatPoint(this.m_vehicles[id].head.pos_data.lon,this.m_vehicles[id].head.pos_data.lat);		
	if (lonLat!=undefined){
		this.map.setCenter(lonLat, );
	}
	*/
}

//public
VehicleLayer.prototype.addVehicle = function(mapMarker,tailMarkers,showPointer,current){
//console.log("VehicleLayer.prototype.addVehicle ID="+mapMarker.id)
	var self = this;
	this.m_vehicles[mapMarker.id] = {
		'head':mapMarker,
		'tail':tailMarkers,
		'pointerFeature':null,
		'currentObjFeature':null
	};
	var features = [];
	//header
	mapMarker.feature = new OpenLayers.Feature.Vector(
			this.getMapPoint(mapMarker.pos_data.lon,mapMarker.pos_data.lat),
			null, this.getCarStyle(mapMarker,current));
			
	//for use in select/unselect functions
	mapMarker.feature.carId = mapMarker.id;
	features.push(mapMarker.feature);
	
	//for pointer
	if (showPointer){
		this.m_vehicles[mapMarker.id].pointerFeature = new OpenLayers.Feature.Vector(
			this.getMapPoint(mapMarker.pos_data.lon, mapMarker.pos_data.lat),
			null, this.getPointerStyle(mapMarker.pos_data.heading)
		);
		features.push(this.m_vehicles[mapMarker.id].pointerFeature);
	}
	
	//for current obj image
	if (current){
		this.setCurrentObj(mapMarker.id);
	}
	
	//tail
	if (tailMarkers!=undefined){
		for (var i=0;i<tailMarkers.length;i++){
			//alert(tailMarkers[i].image);
			tailMarkers[i].feature = new OpenLayers.Feature.Vector(
					this.getMapPoint(tailMarkers[i].lon,tailMarkers[i].lat),
					null, this.getTailStyle(tailMarkers[i]));	
			features.push(tailMarkers[i].feature);
		}
	}
	this.layer.addFeatures(features);
	
	var onMarkerSelect = function(feature){
		if (feature.carId!=undefined&&self.onCarSelect){
			self.onCarSelect(feature.carId);
		}
	};
	
	var selectCtrl = new OpenLayers.Control.SelectFeature(this.layer, {
		hover: false,
		highlightOnly: false,
		renderIntent: "temporary",
		onSelect: onMarkerSelect
	});
	this.map.addControl(selectCtrl);
	selectCtrl.activate();
	
}
VehicleLayer.prototype.removeVehicle = function(carMarkerId){
	if (this.m_vehicles[carMarkerId]!=undefined){
		var features = [];
			//delete from layer
		//pointer
		if (this.m_vehicles[carMarkerId].pointerFeature!=undefined){
			features.push(this.m_vehicles[carMarkerId].pointerFeature);
		}
		
		//car image
		if (this.m_vehicles[carMarkerId].head!=undefined){
			features.push(this.m_vehicles[carMarkerId].head.feature);
		}
		
		//car tail
		if (this.m_vehicles[carMarkerId].tail!=undefined){
			for (var i=0;i<this.m_vehicles[carMarkerId].tail.length;i++){
				features.push(
					this.m_vehicles[carMarkerId].tail[i].feature
					);
			}
		}
		
		//delete from map
		this.removeFromLayer(features);
		
		//deleting object
		//tail
		if (this.m_vehicles[carMarkerId].tail!=undefined){
			for (var i=0;i<this.m_vehicles[carMarkerId].tail.length;i++){
				delete this.m_vehicles[carMarkerId].tail[i];
			}
		}
		//head
		if (this.m_vehicles[carMarkerId].head!=undefined){
			delete this.m_vehicles[carMarkerId].head;
		}
		//itself
		if (this.m_vehicles[carMarkerId]!=undefined){
			delete this.m_vehicles[carMarkerId];
		}
	}
}
VehicleLayer.prototype.getPointerStyle= function(direction){
	var style_mark = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
	
	//image
	
	if (this.OBJ_POINTER_SCALE!=1){
		var img = new Image();
		img.src = TRACK_CONSTANTS.IMG_PATH+TRACK_CONSTANTS.POINTER_IMGS[this.CURRENT_THEME];
		style_mark.graphicHeight = Math.round(img.height*this.OBJ_POINTER_SCALE); 
		style_mark.graphicWidth = Math.round(img.width*this.OBJ_POINTER_SCALE);		
	}
	style_mark.externalGraphic = TRACK_CONSTANTS.IMG_PATH+TRACK_CONSTANTS.POINTER_IMGS[this.CURRENT_THEME];
	var x_offset,y_offset;
	if (direction<180){
		y_offset = -40;
	}
	else{
		y_offset = -40;
	}
	if (x_offset!=undefined){
		style_mark.graphicXOffset = x_offset;
	}
	if (y_offset!=undefined){
		style_mark.graphicYOffset = y_offset;
	}
	style_mark.rotation = direction;
	
	//title
	//style_mark.graphicTitle = tjis.OBJ_POINTER_TITLE;

	style_mark.graphicOpacity = this.CAR_MARKER_OPACITY;
	style_mark.pointRadius = this.CAR_MARKER_POINT_RADIUS;
	return (style_mark);
}

VehicleLayer.prototype.getCarStyle = function(carMarker,current){
	var style_mark = this.getStyle(carMarker);
	
	style_mark.graphicOpacity = (current)? 
				this.CAR_CUR_MARKER_OPACITY:this.CAR_MARKER_OPACITY;
	style_mark.cursor = this.CAR_MARKER_CURSOR;
	
	style_mark.label = carMarker.getLabel();
	if (style_mark.label!=undefined){
		style_mark.labelXOffset = 14;
		style_mark.labelYOffset = 14;
		style_mark.fontSize = '12px';	
	}
	
	//layer_style.fillOpacity = 0.2;
	style_mark.pointRadius = this.CAR_MARKER_POINT_RADIUS;
	return (style_mark);
}
VehicleLayer.prototype.getTailStyle = function(tailMarker){
	var style_mark = this.getStyle(tailMarker);
	
	style_mark.graphicOpacity = this.TAIL_MARKER_OPACITY;
	style_mark.cursor = this.TAIL_MARKER_CURSOR;
	//layer_style.fillOpacity = 0.2;
	style_mark.pointRadius = this.TAIL_MARKER_POINT_RADIUS;
	return (style_mark);
}
VehicleLayer.prototype.setCurrentObj = function(id,zoom){
//console.log("VehicleLayer.prototype.setCurrentObj ID="+id)
	if (this.m_vehicles[id]!=undefined){
		this.currentObj = id;
		//flying
		this.flyToObjById(id,zoom);
	}
}

VehicleLayer.prototype.removeAllVehicles = function(){
	for (var carMarkerId in this.m_vehicles){
		this.removeVehicle(carMarkerId);
	}
}
