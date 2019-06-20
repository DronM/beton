/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ConcreteCostForOwnerHeadEdit(id,options){
	options = options || {};
	options.model = new ConcreteCostForOwnerHeader_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Прайс бетон:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	//options.modelDescrFields = [options.model.getField("comment_text"),options.model.getField("create_date")];
	options.modelDescrFormatFunction = function(fields){
		return fields.comment_text.getValue()+" ("+DateHelper.format(fields.create_date.getValue(),"d/m/y")+")";
	}
	
	var contr = new ConcreteCostForOwnerHeader_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ConcreteCostForOwnerHeadEdit.superclass.constructor.call(this,id,options);
	
}
extend(ConcreteCostForOwnerHeadEdit,EditSelectRef);

