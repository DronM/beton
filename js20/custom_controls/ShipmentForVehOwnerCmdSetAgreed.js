/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2019

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ShipmentForVehOwnerCmdSetAgreed(id,options){
	options = options || {};	

	var cur_d = DateHelper.time();
	this.m_accPeriodStartDescr = DateHelper.format(
		new Date(cur_d.getFullYear(),cur_d.getMonth()-1,1)
		,"d/m/y"
		);
	this.m_accPeriodEndDescr = DateHelper.format(
		DateHelper.monthEnd(new Date(cur_d.getFullYear(),cur_d.getMonth()-1,1))
		,"d/m/y"
		);

	this.TITLE = this.TITLE + " с "+this.m_accPeriodStartDescr+" по "+this.m_accPeriodEndDescr;
	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	options.glyph = "glyphicon-ok";
	options.title = this.TITLE;
	options.caption = "Согласовать все с "+this.m_accPeriodStartDescr+" по "+this.m_accPeriodEndDescr+" ";
		
	ShipmentForVehOwnerCmdSetAgreed.superclass.constructor.call(this,id,options);
		
}
extend(ShipmentForVehOwnerCmdSetAgreed,GridCmd);

/* Constants */
ShipmentForVehOwnerCmdSetAgreed.prototype.TITLE = "Согласовать все несогласованные";
ShipmentForVehOwnerCmdSetAgreed.prototype.METHOD_ID = "owner_set_agreed_all";

/* private members */

/* protected*/


/* public methods */
ShipmentForVehOwnerCmdSetAgreed.prototype.doAgree = function(){
	this.m_grid.setModelToCurrentRow();
	var pm = (new Shipment_Controller()).getPublicMethod(this.METHOD_ID);
	
	var self = this;
	pm.run({
		"ok":function(resp){
			self.m_grid.onRefresh(function(){
				window.showNote("Все документы согласованы");
			});
		}
	})
}

ShipmentForVehOwnerCmdSetAgreed.prototype.onCommand = function(){
	var constants = {"vehicle_owner_accord_from_day":null,"vehicle_owner_accord_to_day":null};
	window.getApp().getConstantManager().get(constants);
	var cur_d = DateHelper.time();
	if(!(cur_d.getDate()>=constants.vehicle_owner_accord_from_day.getValue() && cur_d.getDate()<=constants.vehicle_owner_accord_to_day.getValue())){
		var acc_start = DateHelper.format(
			new Date(cur_d.getFullYear(),cur_d.getMonth(),constants.vehicle_owner_accord_from_day.getValue())
			,"d/m/y"
			);
		var acc_end = DateHelper.format(
			new Date(cur_d.getFullYear(),cur_d.getMonth(),constants.vehicle_owner_accord_to_day.getValue())
			,"d/m/y"
			);
	
		throw new Error("Согласование предыдущего месяца разрешено с "+DateHelper.format(acc_start,"d/m/y")+" по "+DateHelper.format(acc_end,"d/m/y"));
	}
	
	var self = this;
	WindowQuestion.show({
		"yes":true,
		"no":false,
		"cancel":true,
		"text":this.TITLE+"?",
		"callBack":function(res){
			if(res==WindowQuestion.RES_YES){
				self.doAgree();
			}
		}
	});

}
