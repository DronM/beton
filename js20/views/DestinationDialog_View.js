/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function DestinationDialog_View(id,options){	

	options = options || {};
	options.controller = new Destination_Controller();
	options.model = options.models.DestinationDialog_Model;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
			"labelCaption":"Наименование:",
			"required":true,
			"maxLength":100
		}));	
	
		this.addElement(new EditFloat(id+":distance",{
			"labelCaption":"Расстояние (км.):",
		}));	

		this.addElement(new EditTime(id+":time_route",{
			"labelCaption":"Время в пути (часы):",
		}));	

		this.addElement(new EditFloat(id+":price",{
			"labelCaption":"Стоимость доставки:",
		}));	

		var self = this;
		this.addElement(new ButtonCmd(id+":cmdFindOnMap",{
			"caption":"Найти на карте ",
			"glyph":"glyphicon-search",
			"onClick":function(){
				self.findOnMap();
			}
		}));	
	
		this.addElement(new ZoneDrawingControl(id+":map_controls"));	
	
	}
	
	DestinationDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("distance")})
		,new DataBinding({"control":this.getElement("time_route")})
		,new DataBinding({"control":this.getElement("price")})
	];
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")})
		,new CommandBinding({"control":this.getElement("distance")})
		,new CommandBinding({"control":this.getElement("time_route")})
		,new CommandBinding({"control":this.getElement("price")})
	]);
	
}
extend(DestinationDialog_View,ViewObjectAjx);

DestinationDialog_View.prototype.PAM_DIV_ID = "mapdiv";

DestinationDialog_View.prototype.updateZone = function(zoneStr){
console.log("DestinationDialog_View.prototype.updateZone zoneStr="+zoneStr)
	this.getController().getPublicMethod("update").setFieldValue("zone",zoneStr);
	this.getController().getPublicMethod("insert").setFieldValue("zone",zoneStr);
}

DestinationDialog_View.prototype.findOnMap = function(){
	var ctrl = this.getElement("name");
	if(ctrl.isNull())return;
	var pm = (new Destination_Controller()).getPublicMethod("get_coords_on_name");
	pm.setFieldValue("name",ctrl.getValue());
	var self = this;
	pm.run({
		"ok":function(resp){
			var m = resp.getModel("Coords_Model");
			if(m.getNextRow()){
				var lon_lower = m.getFieldValue("lon_lower");
				var lat_lower = m.getFieldValue("lat_lower");
				var lon_upper = m.getFieldValue("lon_upper");
				var lat_upper = m.getFieldValue("lat_upper");
				var zone_str = lon_lower+" "+lat_lower+","+
					lon_lower+" "+lat_upper+","+
					lon_upper+" "+lat_upper+","+
					lon_upper+" "+lat_lower+","+
					lon_lower+" "+lat_lower;							
				self.updateZone(zone_str);
				
				zone_str = zone_str.split(" ").join(",");
				var zone_points = zone_str.split(",");	
				self.m_zones.drawZoneOnCoords(zone_points);
				
				var move_lon = lon_lower + (lon_upper - lon_lower)/2;
				var move_lat = lat_lower + (lat_upper - lat_lower)/2;				
				self.m_zones.moveMapToCoords(move_lon, move_lat,TRACK_CONSTANTS.FOUND_ZOOM);
					
			}
		}
	})
}

DestinationDialog_View.prototype.toDOM = function(parent){

	DestinationDialog_View.superclass.toDOM.call(this,parent);

	this.m_map = new OpenLayers.Map("map",{"controls":[]});
	this.m_layer = new OpenLayers.Layer.OSM();		
	
	this.m_map.addLayer(this.m_layer);		
	
	var zoom_bar = new OpenLayers.Control.PanZoomBar();
	this.m_map.addControl(zoom_bar);	
	this.m_map.addControl(new OpenLayers.Control.LayerSwitcher());
	this.m_map.addControl(new OpenLayers.Control.ScaleLine());
	this.m_map.addControl(new OpenLayers.Control.Navigation());
	
	var zone_str = this.getModel().getFieldValue("zone_str");
	var zone_points = [];
	if(zone_str){
		zone_str = zone_str.split(" ").join(",");
		zone_points = zone_str.split(",");	
		zone_points.splice(zone_points.length-2,2);//remove last point
	}
		
	this.m_zones = new GeoZones(this.m_map,"Объект",zone_points,true);	
	this.getElement("map_controls").setZones(this.m_zones);
	
	this.m_zones.setDrawComplete(this.drawComplete,this);
	
	var zone_center =  this.getModel().getFieldValue("zone_center_str");
	var zone_center_ar = zone_center? zone_center.split(" "):null;
	if (zone_center_ar && zone_center_ar.length>=2){
		move_lon = zone_center_ar[0];
		move_lat = zone_center_ar[1];
		zoom = TRACK_CONSTANTS.FOUND_ZOOM;
	}
	else{
		var constants = {"map_default_lon":null,"map_default_lat":null};
		window.getApp().getConstantManager().get(constants);
		
		move_lon = NMEAStrToDegree(constants.map_default_lon.getValue());
		move_lat = NMEAStrToDegree(constants.map_default_lat.getValue());
		zoom = TRACK_CONSTANTS.INI_ZOOM;
	}
	
	this.m_zones.moveMapToCoords(move_lon, move_lat,zoom);
	
}

DestinationDialog_View.prototype.drawComplete = function(coordsStr){
	console.log("DestinationDialog_View.prototype.drawComplete coordsStr="+coordsStr)
	this.updateZone(coordsStr);
}
