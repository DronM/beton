/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function MaterialSelect(id,options){
	options = options || {};
	
	options.model = new RawMaterial_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Материал:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new RawMaterial_Controller();
	options.readPublicMethod = contr.getPublicMethod(options.forConcrete? "get_list_for_concrete":"get_list");
	
	MaterialSelect.superclass.constructor.call(this,id,options);
	
}
extend(MaterialSelect,EditSelectRef);

