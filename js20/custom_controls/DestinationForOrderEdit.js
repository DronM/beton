/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function DestinationForOrderEdit(id,options){

	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Объект:";
	}
	var self = this;
	options.cmdInsert = true;
	options.cmdSmInsert = true;
	options.buttonInsert = new ButtonInsert(id+":btn_insert",{
		"editControl":this
		,"onClick":function(e){
			if(CommonHelper.isEmpty(this.getEditControl().getKeys())){
				self.openNewDest(this.getEditControl().getNode().value);
			}	
		}
	});

	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = DestinationList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = Destination_Form;
	
	//подсвечивать не записанный объект
	this.m_orig_onSelect = options.onSelect;
	options.onSelect = (function(orig_onSelect){
		return function(fields){
			if(CommonHelper.isEmpty(this.getKeys())){
				//add class
				DOMHelper.addClass(this.getNode(),"null-ref");
			}
			if (orig_onSelect){
				orig_onSelect(fields);
			}
		}
	})(this.m_orig_onSelect);
	
	options.acOnCompleteTextOut = function(textHTML,modelRow){
		var pref = "";
		if(modelRow&&modelRow.is_address.getValue()){
			pref = "<span class='glyphicon glyphicon-envelope'></span> ";
		}
		else if(modelRow&&modelRow.client_dest.getValue()){
			pref = "<i class='icon-user-check'></i> ";
		}
		else if(modelRow){
			//просто зона
			pref = "<i class='icon-truck'></i> ";
		}
		return pref + textHTML;
	}
	
	options.acMinLengthForQuery = (options.acMinLengthForQuery!=undefined)? options.acMinLengthForQuery:1;
	options.acController = new Destination_Controller();
	options.acPublicMethod = options.acController.getPublicMethod("complete_for_order");
	options.acModel = new DestinationForOrderList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name_pat";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	DestinationForOrderEdit.superclass.constructor.call(this,id,options);
}
extend(DestinationForOrderEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

DestinationForOrderEdit.prototype.openNewDest = function(descr){
	var self = this;
	
	var win_w = $( window ).width();
	var h = $( window ).height()-20;//win_w/3*2;
	var left = win_w/3;
	var w = win_w/3*2;//left - 20;

	this.m_mapForm = new Destination_Form({
		"id":CommonHelper.uniqid(),
		"height":h,
		"width":w,
		"left":left,
		"top":10,
		"params":{
			"cmd":"insert"
			,"editViewOptions":{	
				"defDialogValues":{
					"name":descr
				}							
			}
		},
		"onClose":function(res){
			res = res || {"updated":false};
			console.log(res)
			self.m_mapForm.close();
			delete self.m_mapForm;			
		}
	});
	this.m_mapForm.open();
}


