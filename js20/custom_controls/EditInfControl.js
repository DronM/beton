/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2012
 
 * @class
 * @classdesc Visual error control
 
 * @param {string} id
 * @param {Object} options
 * @param {string} [options.errorClassName=this.DEF_ERROR_CLASS]
 * @param {string} [options.tagName=this.DEF_TAG]
 */
function ErrorControl(id,options){
	options = options || {};

	ErrorControl.superclass.constructor.call(this, id, options.tagName || this.DEF_TAG, options);
	
	this.m_errorclassName = options.errorClassName || this.DEF_ERROR_CLASS;
}
extend(ErrorControl,Control);

/* constants */
ErrorControl.prototype.DEF_ERROR_CLASS = "label label-danger";
ErrorControl.prototype.DEF_TAG = "DIV";

ErrorControl.prototype.setValue = function(val){
	if (!val || val.trim()==""){
		DOMHelper.delClass(this.getNode(),this.m_errorclassName);
	}
	else{
		DOMHelper.addClass(this.getNode(),this.m_errorclassName);
	}
	ControlContainer.superclass.setValue.call(this,val);
}
ErrorControl.prototype.clear = function(){
	this.setValue("");
}
