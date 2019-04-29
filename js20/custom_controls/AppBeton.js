/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {namespace} options
 */	
function AppBeton(options){
	options = options || {};
	
	options.lang = "rus";	
	options.paginationClass = Pagination;
	
	this.setColorClass(options.servVars.color_palette || this.COLOR_CLASS);
	
	AppBeton.superclass.constructor.call(this,"AppBeton",options);
	
	if (this.storageGet(this.getSidebarId())=="xs"){
		$('body').toggleClass('sidebar-xs');
	}
}
extend(AppBeton,App);

/* Constants */

AppBeton.prototype.DEF_phoneEditMask = "8-(999)-999-99-99";

/* private members */
AppBeton.prototype.m_colorClass;

/* protected*/

AppBeton.prototype.makeItemCurrent = function(elem){
	if (elem){
		var l = DOMHelper.getElementsByAttr("active", document.body, "class", true,"LI");
		for(var i=0;i<l.length;i++){
			DOMHelper.delClass(l[i],"active");
		}
		DOMHelper.addClass(elem.parentNode,"active");
		if (elem.nextSibling){
			elem.nextSibling.style="display: block;";
		}
	}
}

AppBeton.prototype.showMenuItem = function(item,c,f,t,extra,title){
	AppBeton.superclass.showMenuItem.call(this,item,c,f,t,extra,title);
	this.makeItemCurrent(item);
}


/* public methods */
AppBeton.prototype.getSidebarId = function(){
	return this.getServVar("user_name")+"_"+"sidebar-xs";
}
AppBeton.prototype.toggleSidebar = function(){
	var id = this.getSidebarId();
	this.storageSet(id,(this.storageGet(id)=="xs")? "":"xs");
}

AppBeton.prototype.formatError = function(erCode,erStr){
	return (erStr +( (erCode)? (", код:"+erCode):"" ) );
}

AppBeton.prototype.getColorClass = function(){
	return this.m_colorClass;
}
AppBeton.prototype.setColorClass = function(v){
	this.m_colorClass = v;
}

AppBeton.prototype.formatCellStr = function(fVal,cell,len){
	var res = "";
	if(fVal && fVal.length>len+2){
		cell.setAttr("title",fVal);
		res = fVal.substr(0,len)+"...";
	}
	else if(fVal){
		res = fVal;
	}
	return res;
}

AppBeton.prototype.formatCell = function(field,cell,len){
	var res = "";
	if(field&&!field.isNull()){
		var f_val = field.getValue();
		if(typeof f_val=="object")
			f_val = f_val.getDescr();
		/*	
		if(f_val&&f_val.length>len+2){
			cell.setAttr("title",f_val);
			res = f_val.substr(0,len)+"...";
		}
		else if(f_val){
			res = f_val;
		}
		*/
		res = this.formatCellStr(f_val,cell,len);
	}
	return res;
}

