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
/*App.prototype.m_serverTemplateIds = [
	"ProductionMaterialList"
];
*/
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

AppBeton.prototype.getProdSiteModel = function(){
	if(!this.m_prodSite_Model){
		var self = this;
		(new ProductionSite_Controller()).getPublicMethod("get_list").run({
			"async":false,
			"ok":function(resp){
				self.m_prodSite_Model = resp.getModel("ProductionSite_Model");
			}
		})
	}
	return this.m_prodSite_Model;
}

AppBeton.prototype.makeGridNewDataSound = function(){
	var audio = new Audio("img/Bell-sound-effect-ding.mp3");
	audio.play();
	//console.log("AppBeton.prototype.makeGridNewDataSound")
}

AppBeton.prototype.makeCallContinue = function(tel){
	if(this.getServVar("debug")==1){
		window.showTempNote("ТЕСТ Пытаемся позвонить на номер: "+tel,null,10000);
		return;
	}
	
	var pm = (new Caller_Controller()).getPublicMethod("call");
	pm.setFieldValue("tel",tel);
	pm.run({
		"ok":function(resp){
			window.showTempNote("Пытаемся позвонить на номер: "+tel,null,10000);
		}
	})
}

AppBeton.prototype.makeCall = function(tel){
	if(!window.Caller_Controller){
		throw new Error("Контроллер Caller_Controlle не определен!");
	}
	var self = this;
	WindowQuestion.show({
		"cancel":false,
		"text":"Набрать номер "+tel+"?",
		"callBack":function(res){
			if(res==WindowQuestion.RES_YES){
				self.makeCallContinue(tel);
			}
		}
	});
}

/**
 * opens dialog form
 */
AppBeton.prototype.materialQuantCorrection = function(fields){
	var mat_id = fields.material_id.getValue();
	this.m_materialDifStore = this.m_materialDifStore || {};
	if(this.m_materialDifStore["id"+mat_id]==undefined){
		//get attribute
		var self = this;
		var pm = (new RawMaterial_Controller()).getPublicMethod("get_object");
		pm.setFieldValue("id",mat_id);
		pm.run({
			"ok":(function(fields,matId){
				return function(resp){
					var m = resp.getModel("RawMaterial_Model");
					if(m.getNextRow()){
						var dif_store = m.getFieldValue("dif_store");
						self.m_materialDifStore["id"+matId] = dif_store;
						self.materialQuantCorrectionCont(fields,dif_store);
					}
				}
			})(fields,mat_id)
		});
	}
	else{
		this.materialQuantCorrectionCont(fields,this.m_materialDifStore["id"+mat_id]);
	}	
}

AppBeton.prototype.materialQuantCorrectionCont = function(fields,matDifStore){
	var self = this;
	var elements = [];
	if(matDifStore){
		elements.push(
			new ProductionSiteEdit("CorrectQuant:cont:production_sites_ref",{
				"labelCaption":"Завод:",
				"required":"true",
				"focus":(!fields.production_site_id),
				"enabled":(!fields.production_site_id),
				"value":fields.production_site_id
			})
		);
	}
	elements.push(
		new EditFloat("CorrectQuant:cont:quant",{
			"labelCaption":"Количество:",
			"length":19,
			"precision":4,
			"focus":!(matDifStore&&!fields.production_site_id)
		})
	);
	elements.push(
		new EditText("CorrectQuant:cont:comment_text",{
			"labelCaption":"Комментарий:",
			"rows":3
		})
	);
	
	this.m_viewMatertialQuantCorrect = new EditJSON("CorrectQuant:cont",{
		"elements":elements
	});
	this.m_formMatertialQuantCorrect = new WindowFormModalBS("CorrectQuant",{
		"content":this.m_viewMatertialQuantCorrect,
		"cmdCancel":true,
		"cmdOk":true,
		"contentHead":"Корректировка количества "+fields.material_descr.getValue(),
		"onClickCancel":function(){
			self.closeMatertialQuantCorrect();
		},
		"onClickOk":(function(matDifStore,self){
			return function(){
				var res = self.m_viewMatertialQuantCorrect.getValueJSON();
				if(!res||!res.production_sites_ref||res.production_sites_ref.isNull()){
					throw new Error("Не указан завод!");
				}
				self.setMatertialQuantCorrectOnServer(res,matDifStore,self.m_viewMatertialQuantCorrect.fieldValues);
			}
		})(matDifStore,self)
	});
	this.m_viewMatertialQuantCorrect.fieldValues = {
		"material_id":fields.material_id.getValue(),		
		"material_descr":fields.material_descr.getValue()
	}
	this.m_formMatertialQuantCorrect.open();
}

AppBeton.prototype.setMatertialQuantCorrectOnServer = function(newValues,matDifStore,fieldValues){
	var self = this;
	var pm = (new MaterialFactBalanceCorretion_Controller()).getPublicMethod("insert");
	pm.setFieldValue("material_id",fieldValues.material_id);
	pm.setFieldValue("comment_text",newValues.comment_text);
	pm.setFieldValue("required_balance_quant",newValues.quant);
	if(matDifStore){
		pm.setFieldValue("production_site_id",newValues.production_sites_ref.getKey("id"));
	}
	else{
		pm.resetFieldValue("production_site_id");
	}
	pm.run({
		"ok":function(){
			window.showTempNote(fieldValues.material_descr+": откорректирован остаток на утро",null,5000);				
			self.closeMatertialQuantCorrect();
			self.m_refresh();
		}
	})	
}

AppBeton.prototype.closeMatertialQuantCorrect = function(){
	this.m_viewMatertialQuantCorrect.delDOM()
	this.m_formMatertialQuantCorrect.delDOM();
	delete this.m_viewMatertialQuantCorrect;
	delete this.m_formMatertialQuantCorrect;			
}

AppBeton.prototype.getChartColors = function(){
	if(!this.m_chartColors){
		this.m_chartColors = {
			red: 'rgb(255, 99, 132)',
			orange: 'rgb(255, 159, 64)',
			yellow: 'rgb(255, 205, 86)',
			green: 'rgb(75, 192, 192)',
			blue: 'rgb(54, 162, 235)',
			purple: 'rgb(153, 102, 255)',
			grey: 'rgb(201, 203, 207)'
		};	
	}
	return this.m_chartColors;
}
