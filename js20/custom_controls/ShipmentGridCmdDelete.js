/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2019

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ShipmentGridCmdDelete(id,options){
	options = options || {};	

	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	
	var self = this;
	this.m_btn = new ButtonCmd(id+"btn",{
		"caption":"Удалить ",
		"glyph":"glyphicon-remove",
		"title":"Удалить отгрузку",
		"onClick":function(){
			self.deleteShipment();
		}
	});
	
	options.controls = [
		this.m_btn
	]
	
	ShipmentGridCmdDelete.superclass.constructor.call(this,id,options);
		
}
extend(ShipmentGridCmdDelete,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ShipmentGridCmdDelete.prototype.setGrid = function(v){
	ShipmentGridCmdDelete.superclass.setGrid.call(this,v);
	
	this.m_btn.m_grid = v;
	this.m_grid = v;
}

ShipmentGridCmdDelete.prototype.deleteShipment = function(){
	this.m_grid.setModelToCurrentRow();
	var f = this.m_grid.getModel().getFields();
	var id = f.id.getValue();
	var shipped = f.shipped.getValue();
	var self = this;
	WindowQuestion.show({
		"yes":true,
		"cancel":false,
		"no":true,
		"text":shipped? "Удалить отгрузку с вводом комментария?":"Удалить назначение?",
		"callBack":function(res){
			if(res==WindowQuestion.RES_YES){
				if(shipped){
					self.deleteShipped(id);
				}
				else{
					self.deleteAssigned(id);
				}
			}
		}
	});	
}

ShipmentGridCmdDelete.prototype.deleteShippedCont = function(id,commentText){
	var pm = (new Shipment_Controller()).getPublicMethod("delete_shipped");
	pm.setFieldValue("shipment_id",id);
	pm.setFieldValue("comment_text",commentText);
	
	this.closeComment();
	
	var self = this;
	pm.run({
		"ok":function(resp){
			window.showTempNote("Отгрузка удалена.",function(){				
				self.m_grid.onRefresh();
			},2000);
		}
	})
}

ShipmentGridCmdDelete.prototype.deleteShipped = function(shipmentId){
	var self = this;
	this.m_view = new EditJSON("ShDelete:cont",{
		"elements":[
			new EditText("ShDelete:cont:comment_text",{
				"labelCaption":"Причина удаления:",
				"rows":3
			})
		]
	});
	this.m_form = new WindowFormModalBS("ShDelete",{
		"content":this.m_view,
		"cmdCancel":true,
		"cmdOk":true,
		"onClickCancel":function(){
			self.closeComment();
		},
		"onClickOk":function(){
			var res = self.m_view.getValueJSON();
			if(!res||!res.comment_text||!res.comment_text.length){
				throw new Error("Не указана причина удаления отгрузки!");
			}
			self.deleteShippedCont(shipmentId,res.comment_text);
		}
	});
	
	this.m_form.open();

}

ShipmentGridCmdDelete.prototype.closeComment = function(){
	this.m_view.delDOM()
	this.m_form.delDOM();
	delete self.m_view;
	delete self.m_form;			
}


ShipmentGridCmdDelete.prototype.deleteAssigned = function(id){
	var pm = (new Shipment_Controller()).getPublicMethod("delete_assigned");
	pm.setFieldValue("shipment_id",id);
	var self = this;
	pm.run({
		"ok":function(resp){
			window.showTempNote("Назначение удалено.",function(){
				self.m_grid.onRefresh();
			},2000);
		}
	});
}
