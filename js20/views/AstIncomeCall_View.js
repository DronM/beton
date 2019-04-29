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
function AstIncomeCall_View(id,options){

	options = options || {};
	options.controller = new AstCall_Controller();
	options.model = options.models.AstCallCurrent_Model;

	var client_id;
	if (options.model.getNextRow()){
		var pm = options.controller.getPublicMethod("update");
		pm.setFieldValue("unique_id",options.model.getFieldValue("unique_id"));
		pm.setFieldValue("contact_tel",options.model.getFieldValue("contact_tel"));
		client_id = options.model.getFieldValue("client_id");
		if(client_id)
			pm.setFieldValue("client_id",client_id);
	}

	options.templateOptions = options.templateOptions || {};
	options.templateOptions.isClient = client_id? true:false;

	this.m_onMakeOrder = options.onMakeOrder;

	var self = this;
	options.addElement = function(){
		this.addElement(new EditPhone(id+":contact_tel",{
			"labelCaption":"Телефон:",
			"enabled":false,
			"cmdClear":false
		}));	
	
		this.addElement(new EditString(id+":contact_name",{
			"labelCaption":"Контактное лицо:",
			"maxLength":200
		}));	

		this.addElement(new EditText(id+":manager_comment",{
			"labelCaption":"Комментарий звонка:",
			"rows":"2",
			"maxLength":1000,
			"cmdClear":false
		}));	

		this.addElement(new ClientEdit(id+":client",{
			"cmdInsert":true
		}));	

		this.addElement(new Enum_client_kinds(id+":client_kind",{
			"labelCaption":"Тип:"
		}));
		
		this.addElement(new ClientTypeEdit(id+":client_type"));
		
		this.addElement(new ClientComeFromEdit(id+":client_come_from",{
		}));
		
		/*this.addElement(new EditMoney(id+":client_debt",{
			"labelCaption":"Задолженность:",
			"enabled":false
		}));								
		*/
		
		if(client_id){
			this.addElement(new AstCallClientCallHistoryList_View(id+":client_call_history",{
				"detail":true,
				"models":{
					"AstCallClientCallHistoryList_Model":options.models.AstCallClientCallHistoryList_Model
				}
			}));			

			this.addElement(new AstCallClientShipHistoryList_View(id+":client_ship_history",{
				"detail":true,
				"models":{
					"AstCallClientShipHistoryList_Model":options.models.AstCallClientShipHistoryList_Model
				}			
			}));			
		}
		
		this.addElement(new ButtonCmd(id+":cmdUpdate",{
			"caption":"Изменить  ",
			"glyph":"glyphicon-pencil",
			"onClick":function(){
				
				self.getElement("cmdUpdate").setEnabled(false);
				self.onSave(
					null,
					function(resp,errCode,errStr){						
						self.setError(window.getApp().formatError(errCode,errStr));
					},
					function(){
						self.getElement("cmdUpdate").setEnabled(true);
					}
				);
			}
		})
		);			

		this.addElement(new OrderCalc_View(id+":calc",{
			"calc":true,
			"getPayCash":function(){
				return true;
			}
		}));			
	
		this.addElement(new ButtonCmd(id+":cmdMakeOrder",{
			"caption":"Оформить заявку  ",
			"glyph":"glyphicon-plus",
			"onClick":function(){
				self.m_onMakeOrder();
			}
		})
		);			
	
	}
	
	options.cmdOk = false;
	options.cmdCancel = false;
	options.cmdSave = false;
	
	AstIncomeCall_View.superclass.constructor.call(this,id,options);
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("contact_name")})
		,new DataBinding({"control":this.getElement("contact_tel")})
		//,new DataBinding({"control":this.getElement("client_manager_descr")})
		,new DataBinding({"control":this.getElement("manager_comment")})
		,new DataBinding({"control":this.getElement("client"),"fieldId":"clients_ref"})
		,new DataBinding({"control":this.getElement("client_kind")})
		,new DataBinding({"control":this.getElement("client_type"),"fieldId":"client_types_ref"})
		,new DataBinding({"control":this.getElement("client_come_from"),"fieldId":"client_come_from_ref"})
		//,new DataBinding({"control":this.getElement("client_debt")})
	];
	this.setDataBindings(r_bd);
	
	var write_b = [
		new CommandBinding({"control":this.getElement("contact_name")})
		,new CommandBinding({"control":this.getElement("contact_tel")})
		,new CommandBinding({"control":this.getElement("manager_comment")})		
		,new CommandBinding({"control":this.getElement("client"),"fieldId":"client_id"})
		,new CommandBinding({"control":this.getElement("client_come_from"),"fieldId":"client_come_from_id"})
		,new CommandBinding({"control":this.getElement("client_type"),"fieldId":"client_type_id"})
		,new CommandBinding({"control":this.getElement("client_kind")})
	];
	this.setWriteBindings(write_b);
	
	if(client_id){
		this.addDetailDataSet({
			"control":this.getElement("client_call_history").getElement("grid"),
			"controlFieldId":"client_id",
			"value":client_id
		});

		this.addDetailDataSet({
			"control":this.getElement("client_ship_history").getElement("grid"),
			"controlFieldId":"client_id",
			"value":client_id
		});
	}	
}
//ViewObjectAjx,ViewAjxList
extend(AstIncomeCall_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

