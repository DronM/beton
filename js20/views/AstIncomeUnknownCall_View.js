/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ViewObjectAjx
 * @requires core/extend.js
 * @requires controls/ViewObjectAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function AstIncomeUnknownCall_View(id,options){

	options = options || {};
	
	this.m_options = options;
	
	options.templateOptions = options.templateOptions || {};
	//mask
	var input = new Control(this.getId()+":maskTel","input",{"attrs":{"value":options.models.AstCallCurrent_Model.getFieldValue("contact_tel")},"visible":false});
	$(input.getNode()).mask(window.getApp().getPhoneEditMask());	
	options.templateOptions.contact_tel = input.m_node.value;
	
	this.m_onSetClientBuyer = options.onSetClientBuyer;
	
	var self = this;
	options.addElement = function(){
	
		this.addElement(new ButtonCmd(id+":cmdSetClientBuyer",{
			"caption":"Клиент ",
			"glyph":"glyphicon-plus",
			"onClick":function(){
					self.cmdSetClientType("buyer");
				}
			})
		);				
		
		this.addElement(new ButtonCmd(id+":cmdSetClientAcc",{
			"caption":"Бухгалтерия",
			"glyph":null,
			"onClick":function(){
					self.cmdSetClientType("acc");
				}
			})
		);				

		this.addElement(new ButtonCmd(id+":cmdSetClientElse",{
			"caption":"Прочие",
			"glyph":null,
			"onClick":function(){
					self.cmdSetClientType("else");
				}
			})
		);				
		
	}
	
	AstIncomeUnknownCall_View.superclass.constructor.call(this,id,options);	
}
extend(AstIncomeUnknownCall_View,View);	

AstIncomeUnknownCall_View.prototype.cmdSetClientType = function(tp){
	var pm = (new AstCall_Controller()).getPublicMethod("set_active_call_client_kind");
	pm.setFieldValue("kind", tp);
	pm.setFieldValue("id", this.m_options.models.AstCallCurrent_Model.getFieldValue("unique_id"));
	var self = this;
	pm.run({
		"ok":function(resp){
			var m = resp.getModel("InsertedId_Model");
			if (m && m.getNextRow()){
				var cl = new RefType({
					"keys":{"id":m.getFieldValue("client_id")},
					"descr":m.getFieldValue("client_name"),
					"dataType":"clients"
				});
				self.m_options.models.AstCallCurrent_Model.setFieldValue("client_id", m.getFieldValue("client_id"));
				self.m_options.models.AstCallCurrent_Model.setFieldValue("client_kind", tp);
				self.m_options.models.AstCallCurrent_Model.setFieldValue("clients_ref", cl);
			}
			
			self.m_onSetClientBuyer(self.m_options);
		}
	})
}
