/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2020

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ProductionMaterialListGridDelCmd(id,options){
	options = options || {};	

	options.showCmdControl = true;
	options.glyph = "glyphicon-remove";
	options.title="Удалить материал из производства";
	options.caption = " Удалить ";
	
	this.m_productionId = options.production_id;
	this.m_productionSiteId = options.production_site_id;
	
	ProductionMaterialListGridDelCmd.superclass.constructor.call(this,id,options);
		
}
extend(ProductionMaterialListGridDelCmd,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ProductionMaterialListGridDelCmd.prototype.onCommand = function(){
	this.m_grid.setModelToCurrentRow();
	var model = this.m_grid.getModel();
	var m_descr = model.getFieldValue("materials_ref").getDescr();
	var sil_ref = model.getFieldValue("cement_silos_ref");
	if(sil_ref&&!sil_ref.isNull()){
		m_descr+=" (силос:"+sil_ref.getDescr()+")";
	}

	var self = this;
	WindowQuestion.show({
		"text":"Удалить материал "+m_descr+" из производства?"
		,"no":false
		,"callBack":function(res){
			if(res==WindowQuestion.RES_YES){
				self.onCommandCont(model.getFieldValue("material_id"),model.getFieldValue("cement_silo_id"),m_descr);
			}
		}
	});
}

ProductionMaterialListGridDelCmd.prototype.onCommandCont = function(materialId,cementSiloId,materialDescr){	
	var pm = (new MaterialFactConsumption_Controller()).getPublicMethod("delete_material");	
	
	pm.setFieldValue("production_site_id",this.m_productionSiteId);
	pm.setFieldValue("production_id",this.m_productionId);
	pm.setFieldValue("material_id",materialId);
	pm.setFieldValue("cement_silo_id",cementSiloId);
	
	var self = this;
	pm.run({
		"ok":function(resp){
			self.m_grid.onRefresh(function(){								
				window.showTempNote("Удален материал "+materialDescr+" из производства.",null,5000);				
			});
		}
	})
}

