/** Copyright (c) 2019 
	Andrey Mikhalevich, Katren ltd.
*/

function ZoneDrawingControl(id,options){
	options = options || {};
	
	var self = this;
	options.addElement = function(){
		this.addElement(new ButtonCmd(id+":btn_delete",{
			"onClick":function(){
				self.m_zones.deleteZone.call(self.m_zones);
			},
			"caption":"Удалить",
			"title":"Удалить зону с карты"
		}));
	}
	
	ZoneDrawingControl.superclass.constructor.call(this,id,"DIV",options);	
}
extend(ZoneDrawingControl,ControlContainer);

ZoneDrawingControl.prototype.setZones = function(zones){
	this.m_zones = zones;
}

ZoneDrawingControl.prototype.toDOM = function(parent){
	ZoneDrawingControl.superclass.toDOM.call(this,parent);
	var self = this;
	EventHelper.add(document.getElementById(this.getId()+":drag"), "change",function(){
		self.m_zones.activateDragging.call(self.m_zones);
	});
	
	EventHelper.add(document.getElementById(this.getId()+":draw"), "change",function(){
		self.m_zones.activateDrawing.call(self.m_zones);
	});

	EventHelper.add(document.getElementById(this.getId()+":navigate"), "change",function(){
		self.m_zones.activateNavigation.call(self.m_zones);
	});
	
}
