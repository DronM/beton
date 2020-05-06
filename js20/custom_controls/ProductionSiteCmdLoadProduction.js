/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2020

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ProductionSiteCmdLoadProduction(id,options){
	options = options || {};	

	options.showCmdControl = (options.showCmdControl!=undefined)? options.showCmdControl:true;
	
	var self = this;
	this.m_btn = new ButtonCmd(id+"btn",{
		"caption":"Загрузить данные прозводства по номеру ",
		"glyph":"glyphicon-refresh",
		"title":"Загрузить данные производства из Elkon",
		"onClick":function(){
			self.doanloadProduction();
		}
	});
	
	options.controls = [
		this.m_btn
	]
	
	ProductionSiteCmdLoadProduction.superclass.constructor.call(this,id,options);
		
}
extend(ProductionSiteCmdLoadProduction,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ProductionSiteCmdLoadProduction.prototype.setGrid = function(v){
	ProductionSiteCmdLoadProduction.superclass.setGrid.call(this,v);
	
	this.m_btn.m_grid = v;
	this.m_grid = v;
}

ProductionSiteCmdLoadProduction.prototype.doanloadProduction = function(){
	this.m_grid.setModelToCurrentRow();
	var f = this.m_grid.getModel().getFields();
	var id = f.id.getValue();

	var self = this;
	this.m_view = new View("dialog:cont",{
		"elements":[
			new EditNum("dialog:cont:production_id",{
				"labelCaption":"№ производства Elkon:",
				"focus":true
			})
		]
	});
	this.m_form = new WindowFormModalBS("dialog",{
		"content":this.m_view,
		"dialogWidth":"20%",
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Введите номер производства для загрузки",
		"onClickCancel":function(){
			self.closeSelect();
		},
		"onClickOk":(function(productionSiteId){
			return function(){	
				var pr = self.m_view.getElement("production_id").getValue();
				if(!pr){
					throw Error("Не задан номер производства!");
				}
				self.closeSelect(productionSiteId,pr);
			}
		})(id)
		
	});
	
	this.m_form.open();

	
}

ProductionSiteCmdLoadProduction.prototype.closeSelect = function(productionSiteId,productionId){
	if(this.m_view){
		this.m_view.delDOM()	
		delete this.m_view;
	}
	if(this.m_form){
		this.m_form.delDOM();	
		delete this.m_form;
	}	
	
	if(productionSiteId&&productionId){
		var pm = (new Production_Controller()).getPublicMethod("check_production");
		var self = this;
		
		pm.setFieldValue("production_site_id",productionSiteId);
		pm.setFieldValue("production_id",productionId);
		window.setGlobalWait(true);
		pm.run({
			"ok":function(){
				window.showTempNote("Данные производства загружены",null,5000);
			}
			,"all":function(){
				window.setGlobalWait(false);
			}
		});
	}
}

