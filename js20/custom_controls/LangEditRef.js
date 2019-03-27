/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function LangEditRef(id,options){
	options = options || {};
	options.model = new Lang_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Язык:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new Lang_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	LangEditRef.superclass.constructor.call(this,id,options);
	
}
extend(LangEditRef,EditSelectRef);

