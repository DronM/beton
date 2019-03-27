/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends Button
 * @requires core/extend.js
 * @requires controls/Button.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function RawMaterialConsRateCalcBtn(id,options){
	options = options || {};	
		
	if(options.cmd){
		options.colorClass = "bg-"+window.getApp().getColorClass();//"bg-blue-400";
		options.className = "btn "+options.colorClass+" btn-cmd";
		options.caption = "Пересчитать ";
	}
	else{
		options.className = "btn btn-default";
	}

	options.glyph = "glyphicon-flash";
	options.title="Пересчитать расход за период";

	var self = this;
	options.onClick = function(){
		self.onClick();
	}
	
	this.m_cmd = options.cmd;
	
	RawMaterialConsRateCalcBtn.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(RawMaterialConsRateCalcBtn,Button);

/* Constants */


/* private members */

/* protected*/
RawMaterialConsRateCalcBtn.prototype.m_grid;

/* public methods */
RawMaterialConsRateCalcBtn.prototype.onClick = function(){
	var id,pm,period_str;
	if(this.m_cmd){
		this.m_grid.setModelToCurrentRow();
		id = this.m_grid.getModel().getFieldValue("id");
		period_str = this.m_grid.getModel().getFieldValue("period");
		pm = this.m_grid.getReadPublicMethod().getController().getPublicMethod("recalc_consumption");
		pm.setFieldValue("period_id",id);
	}
	else{
		//var keys = CommonHelper.unserialize(this.gridColumn.gridCell.m_row.getAttr("keys"));
		var tr = DOMHelper.getParentByTagName(this.m_node,"tr");
		if(!tr){
			throw new Error("TR tag not found!");
		}
		var keys = CommonHelper.unserialize(tr.getAttribute("keys"));
		id = keys.id;
		this.gridColumn.getGrid().setModelToCurrentRow(tr);
		period_str = this.m_grid.getModel().getFieldValue("period");
		pm = this.gridColumn.getGrid().getReadPublicMethod().getController().getPublicMethod("recalc_consumption");
		pm.setFieldValue("period_id",id);
	}
	var self = this;
	WindowQuestion.show({
		"text":"Пересчитать расход за период:"+period_str+"?",
		"no":false,
		"callBack":function(res){
			if(res==WindowQuestion.RES_YES){
				self.doRecalc(id,pm);
			}
		}
	});
}

RawMaterialConsRateCalcBtn.prototype.doRecalc = function(id,pm){
	pm.run({
		"ok":function(resp){
			window.showNote("Выполнен пересчет расхода.");
		}
	})
}
