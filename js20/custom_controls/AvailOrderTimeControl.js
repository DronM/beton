/** Copyright (c) 2019 
	Andrey Mikhalevich, Katren ltd.
*/

function AvailOrderTimeControl(id,options){
	options = options || {};
		
	this.m_controller = options.controller;
	this.m_onSetTime = options.onSetTime;
	this.m_onSetSpeed = options.onSetSpeed;
	
	options.addElement = function(){
		this.addElement(new WaitControl(id+":wait"));
		
		this.addElement(new ControlContainer(id+":cont","DIV"));
	}
	
	AvailOrderTimeControl.superclass.constructor.call(this,id,"FIELDSET",options);
}
extend(AvailOrderTimeControl,ControlContainer);

AvailOrderTimeControl.prototype.m_onSetTime;
AvailOrderTimeControl.prototype.m_onSetSpeed;

AvailOrderTimeControl.prototype.m_old_date;
AvailOrderTimeControl.prototype.m_old_quant;
AvailOrderTimeControl.prototype.m_old_speed;

AvailOrderTimeControl.prototype.refresh = function(date,quant,speed){
	if(
	!date||!DateHelper.isValidDate(date)||!quant||!speed
	||((this.m_old_date&&date.getTime()==this.m_old_date.getTime())&&quant==this.m_old_quant&&speed==this.m_old_speed)
	)return;
	
	this.setVisible(true);
	this.getElement("wait").setVisible(true); 
	
	var self = this;
	var pm = this.m_controller.getPublicMethod("get_avail_spots");
	pm.setFieldValue("quant",quant);
	pm.setFieldValue("speed",speed);
	pm.setFieldValue("date",date);
	
	this.m_speed = speed;
//console.log("AvailOrderTimeControl.prototype.refresh ")
//console.log("date="+date)
//console.log("quant="+quant)
//console.log("speed="+speed)				
	pm.run({
		"ok":function(resp){
		
			self.m_old_date = date;
			self.m_old_quant = quant;
			self.m_old_speed = speed;
			self.m_old_select = undefined;
			
			var m = resp.getModel("OrderAvailSpots_Model");
			var ctrl = self.getElement("cont");
			ctrl.clear();
			var i = 0;
			var btn;
			while(m.getNextRow()){
				btn = new ButtonCtrl(ctrl.getId()+":"+i,{
					"caption":DateHelper.format(m.getFieldValue("avail_date_time"),"H:i"),
					"attrs":{
						"class": ("btn btn-default "+( (self.m_speed==m.getFieldValue("avail_speed"))? "normal_speed":"dif_speed"))
					},
					"onClick":function(){
						if(self.m_old_select)DOMHelper.delClass(self.m_old_select,"selected_time");
						DOMHelper.addClass(this.m_node,"selected_time");
						self.m_old_select = this.m_node;
						self.m_onSetTime(this.m_availDateTime);
						self.m_onSetSpeed(this.m_speed);
					}
				});
				btn.m_availDateTime = m.getFieldValue("avail_date_time");
				btn.m_speed = m.getFieldValue("avail_speed");
				ctrl.addElement(btn);
				
				i++;
			}
			ctrl.toDOM();
		},
		"all":function(){
			self.getElement("wait").setVisible(false); 
		}
	});	
}
