/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function CementSiloEdit(id,options){
	options = options || {};
	options.model = new CementSiloList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Силос:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new CementSilo_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	CementSiloEdit.superclass.constructor.call(this,id,options);
	
}
extend(CementSiloEdit,EditSelectRef);

