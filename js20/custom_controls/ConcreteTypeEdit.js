/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ConcreteTypeEdit(id,options){
	options = options || {};
	options.model = new ConcreteTypeList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Марка бетона:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ConcreteType_Controller();
	if(window.getApp().getServVar("role_id")=="client"){
		options.readPublicMethod = contr.getPublicMethod("get_for_client_list");
	}
	else{
		options.readPublicMethod = contr.getPublicMethod("get_list");
	}
	
	ConcreteTypeEdit.superclass.constructor.call(this,id,options);
	
}
extend(ConcreteTypeEdit,EditSelectRef);

