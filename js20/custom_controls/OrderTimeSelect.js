/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function OrderTimeSelect(id,options){
	options = options || {};
	
	options.addNotSelected = false;
		
	var app = window.getApp();
	//if(!app.m_orderTimeElements){
		app.m_orderTimeElements = [];
		
		var constants = {"order_step_min":null,"first_shift_start_time":null,"shift_length_time":null};
		app.getConstantManager().get(constants);

		var step_s = constants.order_step_min.getValue()*60;
		var start_s = DateHelper.timeToMS(constants.first_shift_start_time.getValue()) / 1000;
		var end_s = start_s + DateHelper.timeToMS(constants.shift_length_time.getValue()) / 1000;
	
		var h,m,sec;
		var i = 0;
		while(start_s<end_s){
			//console.log("** New iterration start_s="+start_s)
			h = Math.floor(start_s/3600);
			h = (h<=24)? h:(h-24);
			h = ((h<=9)? "0":"") + h.toString();
			
			m = (start_s % 3600) / 60;
			m = ((m<=9)? "0":"") + m.toString();
			
			var val = (h+":"+m);
			app.m_orderTimeElements.push(new EditSelectOption(id+":"+i,{
				"descr":val,
				"value":val,
				"checked":(options.value==val)
			}));
			
			//console.log("H="+h+" Min="+m)
			start_s+= step_s;
			i++;
		}
	//}
	
	options.elements = app.m_orderTimeElements;
	
	OrderTimeSelect.superclass.constructor.call(this,id,options);
	
}
extend(OrderTimeSelect,EditSelect);

OrderTimeSelect.prototype.setInitValue = function(val){
	val = (val&&typeof(val)=="object")? DateHelper.format(val,"H:i"):val;
	this.setAttr(this.VAL_INIT_ATTR,val);
	this.setValue(val);
}

OrderTimeSelect.prototype.setValue = function(val){
	val = (val&&typeof(val)=="object")? DateHelper.format(val,"H:i"):val;
	OrderTimeSelect.superclass.setValue.call(this,val);
}

