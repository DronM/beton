/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {object} options
 */	
function AppCustom(options){
	options = options || {};
	options.lang = "ru";
	AppCustom.superclass.constructor.call(this,"beton",options);
}
extend(AppCustom,App);

/* Constants */


/* private members */

/* protected*/


/* public methods */
AppCustom.prototype.makeItemCurrent = function(elem){
	var l = DOMHelper.getElementsByAttr("active", document.body, "class", true,"a");
	for(var i=0;i<l.length;i++){
		DOMHelper.delClass(l[i],"active");
	}
	DOMHelper.addClass(elem,"active");
	if (elem.parentNode && elem.parentNode.parentNode && DOMHelper.hasClass(elem.parentNode.parentNode,"collapse") && !DOMHelper.hasClass(elem.parentNode.parentNode,"in")){
		DOMHelper.addClass(elem.parentNode.parentNode,"in");
		DOMHelper.setAttr(elem.parentNode.parentNode,"aria-expanded","true");
	}
}

AppCustom.prototype.showMenuItem = function(item,c,f,t,extra){
	AppCustom.superclass.showMenuItem.call(this,c,f,t,extra);
	if (item)
		this.makeItemCurrent(item);
}

AppCustom.prototype.formatError = function(erCode,erStr){
	return (erStr +( (erCode)? (", код:"+erCode):"" ) );
}

