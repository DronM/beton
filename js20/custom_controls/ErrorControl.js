/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2017
 
 * @class
 * @classdesc Visual error control
 
 * @param {string} id
 * @param {Object} options
 * @param {string} [options.errorClassName=this.DEF_ERROR_CLASS]
 */
function ErrorControl(id,options){
	options = options || {};
	
	options.template = options.template||window.getApp().getTemplate("ErrorControl");
	options.visible = false;
	
	ErrorControl.superclass.constructor.call(this, id, "SPAN", options);
	
}
extend(ErrorControl,Control);

/* constants */
ErrorControl.prototype.DEF_TAG = "SPAN";

ErrorControl.prototype.setValue = function(val,level){
	level = level? level:"danger";
	if (!val || val.trim()==""){
		DOMHelper.addClass(this.getNode(),"hidden");
	}
	else{
		//DOMHelper.delClass(this.getNode(),"hidden");
		
		this.setAttr("class","help-block text-"+level);
		var ic = DOMHelper.getElementsByAttr("icon-cancel-circle2", this.m_node, "class", true,"I");
		if(level!="danger"){		
			DOMHelper.addClass(ic[0],"hidden");
		}
		else{
			DOMHelper.delClass(ic[0],"hidden");
		}
		
	}
	var node;
	if (this.m_node.childNodes){
		for (var i=0;i<this.m_node.childNodes.length;i++){
			if (this.m_node.childNodes[i].nodeType==3){
				this.m_node.childNodes[i].parentNode.removeChild(this.m_node.childNodes[i]);
				break;
			}
		}
	}
	if (!node){
		node = document.createTextNode(val);
		DOMHelper.insertAfter(node,DOMHelper.firstChildElement(this.m_node));		
	}
	node.nodeValue = val;
	
}
ErrorControl.prototype.clear = function(){
	this.setValue("");
}
