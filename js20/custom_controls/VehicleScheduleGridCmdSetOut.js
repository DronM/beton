/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2019

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function VehicleScheduleGridCmdSetOut(id,options){
	options = options || {};	

	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	options.glyph = "glyphicon-ban-circle";
	options.title="Завршить работу (с указанием причины)";
	options.caption = "Завершить работу ";
	
	VehicleScheduleGridCmdSetOut.superclass.constructor.call(this,id,options);
		
}
extend(VehicleScheduleGridCmdSetOut,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
VehicleScheduleGridCmdSetOut.prototype.onCommand = function(){

	var self = this;
	this.m_view = new EditJSON("VSOut:cont",{
		"elements":[
			new EditText("VSOut:cont:comment_text",{
				"labelCaption":"Причина завершения:",
				"rows":3
			})
		]
	});
	this.m_form = new WindowFormModalBS("VSOut",{
		"content":this.m_view,
		"cmdCancel":true,
		"cmdOk":true,
		"onClickCancel":function(){
			self.closeComment();
		},
		"onClickOk":function(){
			var res = self.m_view.getValueJSON();
			if(!res||!res.comment_text||!res.comment_text.length){
				throw new Error("Не указана причина выхода со смены!");
			}
			self.setOutOnServer(res.comment_text);
		}
	});
	
	this.m_form.open();
}

VehicleScheduleGridCmdSetOut.prototype.closeComment = function(){
	this.m_view.delDOM()
	this.m_form.delDOM();
	delete this.m_view;
	delete this.m_form;			
}

VehicleScheduleGridCmdSetOut.prototype.setOutOnServer = function(commentText){
	this.m_grid.setModelToCurrentRow();
	var pm = this.m_grid.getReadPublicMethod().getController().getPublicMethod("set_out");
	
	pm.setFieldValue("id",this.m_grid.getModel().getFieldValue("id"));
	pm.setFieldValue("comment_text",commentText);
	var self = this;
	pm.run({
		"ok":function(resp){
			self.m_grid.onRefresh(function(){
				self.closeComment();
				window.showTempNote("Выведен со смены",null,5000);				
			});
		}
	})
}
