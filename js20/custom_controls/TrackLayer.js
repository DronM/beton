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
	class for holding report layer and its points
*/
function TrackLayer(map,options){
	options = options || {};
	var descr = (options.descr!=undefined)? this.LAYER_DESCR+options.descr:"маршрут";
	TrackLayer.superclass.constructor.call(
		this,map, descr);
	this.points = [];
}
extend(TrackLayer,ObjMapLayer);//base class

//constants
TrackLayer.prototype.popUpWidth = 200;
TrackLayer.prototype.popUpHeight = 100;

TrackLayer.prototype.points;
TrackLayer.prototype.popUp;

//constants
TrackLayer.prototype.LAYER_DESCR = 'Путь для ';

TrackLayer.prototype.clearMarkers = function(){
	var features = [];
	for (var i=0;i<this.points.length;i++){
		if (this.points[i].feature!=undefined){
			features.push(this.points[i].feature);
		}
	}
	if (this.lineFeature!=undefined){
		features.push(this.lineFeature);
	}
	if (features.length>0){
		this.removeFromLayer(features);
	}	
}
TrackLayer.prototype.getPointStyle = function(marker){
	var style_mark = this.getStyle(marker);
	style_mark.fillOpacity = 1;
	
	style_mark.cursor = 'pointer';
	style_mark.labelXOffset = 7;
	style_mark.labelYOffset = 7;
	style_mark.fontSize = '8px';
	//style_mark.label = marker.getLabel();
	
	//layer_style.fillOpacity = 0.2;
	//style_mark.pointRadius = this.CAR_MARKER_POINT_RADIUS;
	return (style_mark);
}

TrackLayer.prototype.addMarkers = function(markers){	
	var self = this;
	//clear first
	this.clearMarkers();
	
	var features = [];
	this.points = markers;
	
   var line_style = {
			strokeColor: "#0074FF",
			strokeWidth: 2,
			//strokeDashstyle: "dashdot",
			pointRadius: 6,
			pointerEvents: "visiblePainted"
		};
	var pointList = [];
	var point;
	for (var i=0;i<this.points.length;i++){
		point = this.getMapPoint(this.points[i].lon,this.points[i].lat);
		this.points[i].feature =
			new OpenLayers.Feature.Vector(
			point,null, this.getPointStyle(this.points[i])
			);
		pointList.push(point);
		//marker.events.register('mousedown', marker, function(evt) { alert(this.icon.url); OpenLayers.Event.stop(evt); });	
		this.points[i].feature.repId = i;
		
		features.push(this.points[i].feature);
	}
	this.layer.addFeatures(features);
	
	//line feature
	this.lineFeature = new OpenLayers.Feature.Vector(
                new OpenLayers.Geometry.LineString(
				pointList),null,line_style
		);	
	this.layer.addFeatures(this.lineFeature);
		
	var onDataSelect = function(feature){
		if (feature.repId!=undefined){
            var popup = new OpenLayers.Popup.FramedCloud("repPointData", 
                                     feature.geometry.getBounds().getCenterLonLat(),
                                     null,
                                     self.points[feature.repId].getCallOut(),
                                     null, true);
            feature.popup = popup;
            self.map.addPopup(popup);
		}
	};
	var onDataUnSelect = function(feature){
		if (feature.repId!=undefined){
            self.map.removePopup(feature.popup);
            feature.popup.destroy();
            feature.popup = null;
		}
	};
	
	var selectCtrl = new OpenLayers.Control.SelectFeature(this.layer, {
		hover: false,
		toggle:true,
		clickout:true,
		highlightOnly: false,
		renderIntent: "temporary",
		onSelect: onDataSelect,
		onUnselect: onDataUnSelect
	});
	this.map.addControl(selectCtrl);
	selectCtrl.activate();
	
}
TrackLayer.prototype.flyToInd = function(ind){
	if (this.points!=undefined && ind<this.points.length){
		var lonLat = this.getLonLatPoint(this.points[ind].lon,this.points[ind].lat);
		if (lonLat!=undefined){
			this.map.setCenter (lonLat, this.map.getZoom());
		}		
	}
}
TrackLayer.prototype.flyToStart = function(){
	this.flyToInd(0);
}
TrackLayer.prototype.flyToEnd = function(){
	if (this.points!=undefined){
		this.flyToInd(this.points.length-1);
	}
}
TrackLayer.prototype.zoomToCenter = function(xMax,xMin,yMax,yMin){
	this.map.setCenter(this.getLonLatPoint((xMax - xMin)/2,(yMax - yMin)/2),
		this.map.getZoom());
	var bounds = new OpenLayers.Bounds();
	bounds.extend(this.getLonLatPoint(xMax,yMax));
	bounds.extend(this.getLonLatPoint(xMin,yMin));
	bounds.toBBOX(); 	
	this.map.zoomToExtent(bounds,true);
}
