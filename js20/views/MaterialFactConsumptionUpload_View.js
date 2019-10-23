/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewList
 * @requires core/extend.js
 * @requires controls/ViewList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MaterialFactConsumptionUpload_View(id,options){
	options = options || {};	

	var role_id = window.getApp().getServVar("role_id");
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.matchingEnabled = (role_id=="admin"||role_id=="owner"||role_id=="boss"||role_id=="supervisor"||role_id=="manager"||role_id=="accountant");
	options.templateOptions.matchingDisabled = !options.templateOptions.matchingEnabled;

	options.templateOptions.productions = [];
	var prod_site_m = window.getApp().getProdSiteModel();
	prod_site_m.reset();
	while(prod_site_m.getNextRow()){
		options.templateOptions.productions.push({
			"productionId":prod_site_m.getFieldValue("id")
			,"productionName":prod_site_m.getFieldValue("name")
		});
	}		
	
	options.addElement = function(){
		for (var i=0;i<options.templateOptions.productions.length;i++){
			var file_ctrl = new EditFile(id+":production_file_"+options.templateOptions.productions[i].productionId,{
				"labelClassName": "control-label",
				"labelCaption":"Файл данных:",
				//"required":true,
				"template":window.getApp().getTemplate("EditFile"),
				"mainView":this,
				"onFileAdded":(function(productionId,fileCtrl){
					console.log("FileAdded for productionId="+productionId)
				})(options.templateOptions.productions[i].productionId,file_ctrl)
			});
			this.addElement(file_ctrl);
			this.addElement(
				new ButtonCmd(id+":cmd_uploading_"+options.templateOptions.productions[i].productionId,{
					"caption":"Загрузить данные",
					"onClick":(function(productionId,fileCtrl,formContext,matchingEnabled){
						return function(){
							var fl = fileCtrl.getValue();
							if(!fl || !fl.length){
								throw new Error("Не выбран файл!");
							}
							var pm = new MaterialFactConsumption_Controller().getPublicMethod("upload_production_file");
							pm.setFieldValue("production_site_id",productionId);
							pm.setFieldValue("production_file",fl);
							window.setGlobalWait(true);
							formContext.getElement("cmd_uploading_"+productionId).setEnabled(false);
							fileCtrl.setEnabled(false);
							pm.run({
								"all":function(){
									formContext.getElement("cmd_uploading_"+productionId).setEnabled(true);
									fileCtrl.setEnabled(true);								
									window.setGlobalWait(false);
									if(matchingEnabled){
										formContext.getElement("material_fact_consumptions_list").getElement("grid").onRefresh();
									}																		
								}
								,"ok":function(resp){
									window.showOk("Файл успешно загружен",null);
								}
							})
						}
					})(options.templateOptions.productions[i].productionId,file_ctrl,this,options.templateOptions.matchingEnabled)
				})
			);			
		}
		
		if (options.templateOptions.matchingEnabled){
			this.addElement(
				new VehicleMapToProductionList_View(id+":vehicle_map_to_production_list")
			);
			this.addElement(
				new ConcreteTypeMapToProductionList_View(id+":concrete_type_map_to_production_list")
			);
			this.addElement(
				new RawMaterialMapToProductionList_View(id+":raw_material_map_to_production_list")
			);

			this.addElement(
				new MaterialFactConsumptionRolledList_View(id+":material_fact_consumptions_list")
			);
			
		}
	}		
				
	MaterialFactConsumptionUpload_View.superclass.constructor.call(this,id,options);
}

extend(MaterialFactConsumptionUpload_View,View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

