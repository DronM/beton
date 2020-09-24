/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2020

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ProductionMaterialListGridInsertCmd(id,options){
	options = options || {};	

	options.showCmdControl = true;
	options.glyph = "glyphicon-plus";
	options.title="Добавить новый материал в производство";
	options.caption = " Добавить ";
	
	this.m_productionId = options.production_id;
	this.m_productionSiteId = options.production_site_id;
	
	ProductionMaterialListGridInsertCmd.superclass.constructor.call(this,id,options);
		
}
extend(ProductionMaterialListGridInsertCmd,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ProductionMaterialListGridInsertCmd.prototype.onCommand = function(){
	
	var self = this;
	this.m_view = new EditJSON("ProdMatAdd:cont",{
		"elements":[
			new MaterialSelect("ProdMatAdd:cont:materials_ref",{
				"labelCaption":"Материал:"
				,"forConcrete":true
				,"required":true
				,"events":{
					"change":function(e){
						self.checkMaterial()
					}
				}
			})
			,new CementSiloEdit("ProdMatAdd:cont:cement_silos_ref",{
				"labelCaption":"Силос:"
				,"required":false
				,"visible":false
				,"events":{
					"change":function(e){
						self.checkMaterial()
					}
				}				
			})
			,new EditFloat("ProdMatAdd:cont:quant_fact",{
				"labelCaption":"Количество (факт):"
				,"precision":"4"
				,"required":true
			})
			
		]
	});
	this.m_form = new WindowFormModalBS("ProdMatAdd",{
		"content":this.m_view,
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Добавление материала в производство",
		"onClickCancel":function(){
			self.closeForm();
		},
		"onClickOk":function(){
			if(self.m_view.validate() && self.checkMaterial()){
				var res = self.m_view.getValueJSON();
				self.addMatOnServer(res);
			}
		}
	});
	
	this.m_form.open();
}

ProductionMaterialListGridInsertCmd.prototype.closeForm = function(){
	this.m_view.delDOM()
	this.m_form.delDOM();
	delete this.m_view;
	delete this.m_form;			
}

ProductionMaterialListGridInsertCmd.prototype.addMatOnServer = function(controls){	

	//через специальный метод!!!
	var pm = (new MaterialFactConsumptionCorretion_Controller()).getPublicMethod("operator_add_material_to_production");	
	
	pm.setFieldValue("production_id",this.m_productionId);
	pm.setFieldValue("production_site_id",this.m_productionSiteId);
	pm.setFieldValue("cement_silo_id",controls.cement_silos_ref? controls.cement_silos_ref.getKey():null);
	pm.setFieldValue("material_id",controls.materials_ref.getKey());
	pm.setFieldValue("cor_quant",controls.quant_fact);
	
	var self = this;
	pm.run({
		"ok":function(resp){
			self.closeForm();
			self.m_grid.onRefresh(function(){								
				window.showTempNote("Добавлен материал в производство.",null,5000);				
			});
		}
	})
}

ProductionMaterialListGridInsertCmd.prototype.checkMaterial = function(){
	var ctrl = this.m_view.getElement("materials_ref");
	var ctrl_silo = this.m_view.getElement("cement_silos_ref");
	
	var fields = ctrl.getModelRow();
	var new_material_id = fields.id.getValue();
	var new_material_cement = fields.is_cement.getValue();
	var new_cement_silos_id;
	if(new_material_cement){
		var new_cem = ctrl_silo.getValue();	
		new_cement_silos_id = (new_cem&&!new_cem.isNull())? new_cem.getKey():null;
	}
	err = false;
	var model = this.m_grid.getModel();
	model.reset();
	while(model.getNextRow()){
		var m_ref = model.getFieldValue("materials_ref");
		var m_id = (m_ref&&!m_ref.isNull())? m_ref.getKey():null
		if(m_id && new_material_id==m_id && !new_material_cement){
			ctrl.setNotValid("Материал уже есть в списке!");
			err = true;
			break;
		}
		else if(m_id && new_material_id==m_id){
			var ref = model.getFieldValue("cement_silos_ref");
			var m_silo_id = (ref&&!ref.isNull())? ref.getKey():null;
			if(m_silo_id && new_cement_silos_id==m_silo_id){
				//throw new Error("Материал с данным силосом уже есть в списке!");
				ctrl_silo.setNotValid("Материал с данным силосом уже есть в списке!");
				err = true;
				break;
			}
		}		
	}
	
	if(!err){
		ctrl.setValid();
		ctrl_silo.setValid();
	}

	ctrl_silo.setVisible(new_material_cement==true);
	ctrl_silo.setRequired(new_material_cement==true);
	
	return !err;
}
