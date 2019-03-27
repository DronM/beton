/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ClientComeFromEdit(id,options){
	options = options || {};
	options.model = new ClientComeFrom_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Источник обращения:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ClientComeFrom_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ClientComeFromEdit.superclass.constructor.call(this,id,options);
	
}
extend(ClientComeFromEdit,EditSelectRef);

