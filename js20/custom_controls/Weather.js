/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends Control
 * @requires core/extend.js
 * @requires controls/Control.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Weather(id,options){
	options = options || {};	
	
	this.m_refreshInterval = (options.refreshInterval||this.DEF_REFRESH)*1000;
	this.m_collapsed = true;
	
	var self = this;
	options.events = {
		"onclick":function(){
			var cont = new Control("WeatherDetails:cont","DIV");
			cont.getNode().innerHTML = self.m_contentDetails;
			(new WindowFormModalBS("WeatherDetails",{
				"contentHead":"Подробности погоды",
				"content":cont,
				"cmdCancel":true
				})
			).open();			
		}
	}
	
	Weather.superclass.constructor.call(this,id,"A",options);
	
	if(options.model)
		this.setData(options.model);
				
}
//ViewObjectAjx,ViewAjxList
extend(Weather,Control);

/* Constants */
Weather.prototype.m_collapsed;
Weather.prototype.CLASS_COLLAPSED = "icon-plus3";
Weather.prototype.CLASS_EXPANDED = "icon-minus3";
Weather.prototype.DEF_REFRESH = 10*60;//every 10 minutes

/* private members */

/* protected*/


/* public methods */
Weather.prototype.toDOM = function(p){
	Weather.superclass.toDOM.call(this,p);
	var self = this;
	this.m_timer = setInterval(function(){
		self.refresh();
	}, this.m_refreshInterval);	
	
	this.refresh();
}

Weather.prototype.delDOM = function(){
	if(this.m_timer)
		clearInterval(this.m_timer);
	
	Weather.superclass.delDOM.call(this);
}

Weather.prototype.setData = function(model){
	if(model&&model.getNextRow()){
		this.getNode().innerHTML = model.getFieldValue("content");
		
		this.m_contentDetails = model.getFieldValue("content_details");
		
		var v = model.getFieldValue("update_dt");
		var upd_dt_s = "";
		if(v){
			upd_dt_s+= "Обновлено в "+ DateHelper.format(v,"H:i");
			/*
			console.log("Update time=");
			console.dir(v);
			upd_dt_s = "Обновлено ";
			var df = DateHelper.time().getTime()-v.getTime();
			df_m = Math.round(df/1000/60);
			h = df_m % 60;
			if(h)upd_dt_s+= h+" ч.";
			m = df_m - h*60;
			if(m)upd_dt_s+= m+" м.";
			upd_dt_s+= " назад";
			*/
		}
		this.setAttr("title",upd_dt_s);
		
	}
}

Weather.prototype.refresh = function(){
	var self = this;
	(new Weather_Controller()).getPublicMethod("get_current").run({
		"ok":function(resp){
			self.setData(resp.getModel("Weather_Model"));
		}
	});
}
