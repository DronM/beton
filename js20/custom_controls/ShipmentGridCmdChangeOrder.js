/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2020

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ShipmentGridCmdChangeOrder(id,options){
	options = options || {};	

	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	
	var self = this;
	this.m_btn = new ButtonCmd(id+"btn",{
		"caption":"Сменить заявку ",
		"glyph":"glyphicon-refresh",
		"title":"Перенести отгрузку в другую заявку",
		"onClick":function(){
			self.changeOrder();
		}
	});
	
	options.controls = [
		this.m_btn
	]
	
	ShipmentGridCmdChangeOrder.superclass.constructor.call(this,id,options);
		
}
extend(ShipmentGridCmdChangeOrder,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ShipmentGridCmdChangeOrder.prototype.setGrid = function(v){
	ShipmentGridCmdChangeOrder.superclass.setGrid.call(this,v);
	
	this.m_btn.m_grid = v;
	this.m_grid = v;
}

ShipmentGridCmdChangeOrder.prototype.changeOrder = function(){
	this.m_grid.setModelToCurrentRow();
	var f = this.m_grid.getModel().getFields();
	var id = f.id.getValue();
	
	var self = this;
	WindowQuestion.show({
		"yes":true,
		"cancel":false,
		"no":true,
		"text":"Выбрать новую завку?",
		"callBack":function(res){
			if(res==WindowQuestion.RES_YES){
				self.changeOrderCont(id);
			}
		}
	});	
}

ShipmentGridCmdChangeOrder.prototype.changeOrderCont = function(shipmentId){
	var self = this;
	this.m_view = new OrderForSelectList_View("OrderList:cont",{
		"onSelect":(function(shipmentId){
			return function(row){
				self.closeSelect(shipmentId,row.id.getValue());
			}
		})(shipmentId)
	});
	this.m_form = new WindowFormModalBS("OrderList",{
		"content":this.m_view,
		"dialogWidth":"100%",
		"cmdCancel":true,
		"cmdOk":false,
		"contentHead":"Выберите новую заявку",
		"onClickCancel":function(){
			self.closeSelect();
		}
	});
	
	this.m_form.open();

}

ShipmentGridCmdChangeOrder.prototype.closeSelect = function(shipmentId,newOrderId){
	if(this.m_view){
		this.m_view.delDOM()	
		delete this.m_view;
	}
	if(this.m_form){
		this.m_form.delDOM();	
		delete this.m_form;
	}	
	
	if(shipmentId&&newOrderId){
		var pm = (new Shipment_Controller()).getPublicMethod("update");
		var self = this;
		pm.setFieldValue("old_id",shipmentId);
		pm.setFieldValue("order_id",newOrderId);
		pm.run({
			"ok":function(){
				if(self.m_grid){
					self.m_grid.onRefresh(function(){
						window.showTempNote("Отгрузка переставлена на другую заявку",null,5000);
					})
				}
				
			}
		});
	}
}

