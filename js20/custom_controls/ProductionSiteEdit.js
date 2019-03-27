/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ProductionSiteEdit(id,options){
	options = options || {};
	options.model = new ProductionSite_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Завод:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ProductionSite_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ProductionSiteEdit.superclass.constructor.call(this,id,options);
	
}
extend(ProductionSiteEdit,EditSelectRef);

