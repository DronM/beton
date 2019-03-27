/* Copyright (c) 2010,2019
	Andrey Mikhalevich, Katren ltd.
*/
/*
	MapMarker
	MapMoveMarker - для отображения точки движения на карте
	MapStaticMarker - для отображения точки стоянки на карте
*/

/**
 * @requires main.js
*/
/*
	MapCarMarker class
	for cars on map
*/
function MapCarMarker(attrs){
	for(var id in attrs){
		this[id] = attrs[id];
	}
}
MapCarMarker.prototype.getHint= function(){
	return from_now_time_dif(DateHelper.strtotime(this.period));	
}
MapCarMarker.prototype.getLabel= function(){
	return this.plate;
}

//возвращает HTML для окна
MapCarMarker.prototype.getCallOut= function(){
	return '<div>!!!Checking!!!'+
		'</div>';
}

/*
	MapMoveMarker class
	for pointers (on move) on map
*/
function MapMoveMarker(attrs){
	for(var id in attrs){
		this[id] = attrs[id];
	}
	
	this.image = TRACK_CONSTANTS.IMG_PATH+
		TRACK_CONSTANTS.POINTER_IMGS[this.theme || TRACK_CONSTANTS.DEF_THEME];
	this.imageRotate = true;
}
MapMoveMarker.prototype.getLabel = function(){
	if (this.showLabel && this.ordNumber){
		return this.ordNumber;
	}
}
MapMoveMarker.prototype.getHint= function(){
	return this.period_str+' ('+this.ordNumber+')';
}
//возвращает HTML для окна
MapMoveMarker.prototype.getCallOut= function(){
	var addRow = function(name,val){
		return '<div class="call_out_row"><div class="call_out_cell">'+
				name+':</div><div class="call_out_cell">'+val+'</div></div>';
	};

	res =   '<div class="call_out"><span class="call_out_header">Информация по точке</span>';
	res+= addRow('объект',this.plate);
	res+= addRow('направление', this.heading_str);
	res+= addRow('дата/время', this.period_str);
	res+= addRow('долгота', this.lon_str);
	res+= addRow('широта', this.lat_str);
	res+= addRow('скорость',this.speed+' км/ч');
	//res+= addRow('адрес', this.address);
			
	if (this.sensorFuelPresent){
		res+= addRow('уровень топлива', this.sensorFuelState);
	}
	if (this.sensorEngPresent){
		res+= addRow('двигатель', this.engine_on_str);
	}
	res+=
	'</div>';
			
	return (res);
}

function MapStopMarker(attrs){
	for(var id in attrs){
		this[id] = attrs[id];
	}
	
	this.image = TRACK_CONSTANTS.IMG_PATH+
		TRACK_CONSTANTS.STOP_IMGS["red"];
	this.imageRotate = false;
}
extend(MapStopMarker,MapMoveMarker);

function sec_dif_to_str(sec_dif){
	var days=0;
	var hours=0;
	var minutes=0;
	var secs=0;
	
	var minutes = Math.floor(sec_dif/60);
	if (minutes<60){
		secs = sec_dif - (minutes*60);
	}
	else{
		hours = Math.floor(minutes/60);
		if (hours<60){
			minutes = minutes - (hours*60);
			secs = 0;
			//sec_dif - (hours*60*60 + minutes*60);
		}
		else{
			days = Math.floor(hours/24);
			hours = hours - (days*24);
			minutes = 0;
			secs = 0;
		}		
	}
	
	var res ='';
	if (days>0){
		res = days+' дн.';
	}
	if (hours>0){
		res += (res=='')?'':' ';
		res += hours+' чс.';
	}
	if (minutes>0){
		res += (res=='')?'':' ';
		res += minutes+' мн.';
	}
	if (secs>0){
		res += (res=='')?'':' ';
		res += secs+' сек.';
	}
	
	return (res);
}

function time_dif_to_str(dtime_start,dtime_end){
	return (dtime_start&&dtime_end)? sec_dif_to_str(Math.floor((dtime_end.getTime() - dtime_start.getTime())/1000)) : "";
}

function from_now_time_dif(dtime){
	var res = time_dif_to_str(dtime,new Date())+' назад';
	
	return (res);

}
