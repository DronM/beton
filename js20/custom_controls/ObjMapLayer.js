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
Converts NMEA string coords to degrees with decim part
*/
function NMEAStrToDegree(str){
	var DEGREE_DIGITS = 2;
	var deg,min;
	//debugger;
	if (str.length){
		str_source = str;
		while ((str_source.substr(0,1)=='0')&&(str_source.length)){
			str_source = str_source.slice(1);
		}
		if (!str_source.isNaN){
			deg = parseFloat(str_source.substr(0,DEGREE_DIGITS));
		}
		if (str_source.length>DEGREE_DIGITS){
			str_source = str_source.slice(DEGREE_DIGITS);
			while ((str_source.substr(0,1)=='0')&&(str_source.length)){
				str_source = str_source.slice(1);
			}
			
			if (!str_source.isNaN)
				var min = parseFloat(str_source);
			return deg + min/60.0;
		}
	}
}

/*
	Base class for holding layers and objects
*/
function ObjMapLayer(map, descr){
	this.layer = new OpenLayers.Layer.Vector(descr);		
	this.map = map;
	this.map.addLayer(this.layer); 
}
ObjMapLayer.prototype.removeLayer = function(){
	this.map.removeLayer(this.layer); 
}
ObjMapLayer.prototype.getStyle = function(marker){
	var style_mark = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
	
	//image
	if (marker.image){
		var scale = (
				(marker.imageScale==undefined)||(marker.imageScale<=0)
				)? 1:marker.imageScale;	
		var img = new Image();
		img.src = marker.image;
		style_mark.externalGraphic = marker.image;
		if (scale!=1){
			style_mark.graphicHeight = Math.round(img.height*scale); 
			style_mark.graphicWidth = Math.round(img.width*scale);		
		}
	}	
	
	//title
	style_mark.graphicTitle = marker.getHint();
	//rotation
	style_mark.rotation = 
			(marker.imageRotate && marker.heading>0)?
			marker.heading:0;
			
	return (style_mark);
}
ObjMapLayer.prototype.removeFromLayer = function(featureArray){
	this.layer.removeFeatures(featureArray);
}
ObjMapLayer.prototype.getMapPoint = function(lon,lat){
	return new OpenLayers.Geometry.Point(lon,lat)
		  .transform(
			new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
			this.map.getProjectionObject() // to Spherical Mercator Projection
		  );
}

ObjMapLayer.prototype.getMapPointFromStr = function(lon,lat){
	return this.getMapPoint(NMEAStrToDegree(lon),NMEAStrToDegree(lat));
}
/*
	returns Point object on coords from DB (in float number format)
*/
ObjMapLayer.prototype.getLonLatPoint = function(lon,lat){
	return new OpenLayers.LonLat(lon,lat)
		  .transform(
			new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
			this.map.getProjectionObject() // to Spherical Mercator Projection
		  );
}

ObjMapLayer.prototype.getLonLatPointFromStr = function(lon,lat){
	return this.getLonLatPoint(
		NMEAStrToDegree(lon),
		NMEAStrToDegree(lat)
		);
}
ObjMapLayer.prototype.moveMapToCoords = function(lon,lat,zoom){
	this.map.setCenter(
		new OpenLayers.LonLat(lon,lat)
		  .transform(
			new OpenLayers.Projection("EPSG:4326"), // transform from WGS 1984
			this.map.getProjectionObject() // to Spherical Mercator Projection
		  ),
		zoom
	);	
}
ObjMapLayer.prototype.moveMapToStrCoords = function(lon,lat,zoom){
	this.moveMapToCoords(NMEAStrToDegree(lon),NMEAStrToDegree(lat),zoom);
}