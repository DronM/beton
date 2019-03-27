function GeoZones(map,objDescr,points,doDraw){
	GeoZones.superclass.constructor.call(this,map,objDescr);	
	
	var self = this;
	if (points && points.length){
		this.drawZoneOnCoords(points);
	}

	//drawing
	if (doDraw){
		this.m_drawControl = new OpenLayers.Control.DrawFeature(this.layer,OpenLayers.Handler.Polygon);
										/*
										{handlerOptions:{sides:4,irregular:true}});		
										*/
		//dragging
		this.m_dragControl = new OpenLayers.Control.DragFeature(this.layer,{
		"onComplete":function(feature,pixel){
			self.drawComplete(feature);
		}
		});
		
		this.map.addControl(this.m_drawControl);	
		this.map.addControl(this.m_dragControl);	
		
		this.layer.events.on({
			featuresadded: function(event){
				self.drawComplete(event.features[0]);
			}
		});		
	}
}
extend(GeoZones,ObjMapLayer);//base class

GeoZones.prototype.m_drawControl;
GeoZones.prototype.m_dragControl;
GeoZones.prototype.m_polygonFeature;
GeoZones.prototype.m_drawComplete;
GeoZones.prototype.m_drawCompleteContext;

GeoZones.prototype.drawZoneOnCoords = function(points){
	if (points.length%2!=0){
		return;
	}
	var pointList = [];
	for (var i=0;i<points.length;i+=2){
		//alert("adding zone coord x="+points[i]+" y="+points[i+1]);
		pointList.push(this.getMapPoint(points[i],points[i+1]));		
	}
	
	var linearRing = new OpenLayers.Geometry.LinearRing(pointList);
	this.m_polygonFeature = new OpenLayers.Feature.Vector(
	new OpenLayers.Geometry.Polygon([linearRing]));
	this.layer.addFeatures(this.m_polygonFeature);
}

GeoZones.prototype.activateDrawing = function(){
	this.deleteZone();
	this.m_drawControl.activate();
	this.m_dragControl.deactivate();
}
GeoZones.prototype.activateNavigation = function(){
	this.m_drawControl.deactivate();
	this.m_dragControl.deactivate();
}
GeoZones.prototype.activateDragging = function(){
	this.m_drawControl.deactivate();
	this.m_dragControl.activate();
}

GeoZones.prototype.makeBigger = function(){
	alert("bigger");
}
GeoZones.prototype.makeSmaller = function(){
	alert("smaller");
}
GeoZones.prototype.deleteZone = function(){
	this.layer.removeAllFeatures();
	if (this.m_drawComplete){
		this.m_drawComplete.call(this.m_drawCompleteCont,"");
	}	
}
GeoZones.prototype.drawComplete = function(feature){
	var vertices = feature.geometry.getVertices();
	var coords_str="";
	for (var i=0;i<vertices.length;i++){
		var point = new OpenLayers.Geometry.Point(vertices[i]["x"],vertices[i]["y"])
				  .transform(
					this.map.getProjectionObject(),
					new OpenLayers.Projection("EPSG:4326")
				  );
		coords_str+=(coords_str=="")? "":",";
		coords_str+=point["x"]+" "+point["y"];
	}
	this.m_drawComplete.call(this.m_drawCompleteCont,coords_str);
}
GeoZones.prototype.setDrawComplete = function(onDrawComplete,context){
	this.m_drawComplete = onDrawComplete;
	this.m_drawCompleteCont = context;
}
