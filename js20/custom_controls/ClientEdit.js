/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function ClientEdit(id,options){

	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Клиент:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	if(options.cmdInsert){
		var self = this;
		options.buttonInsert = new ButtonInsert(id+":cmdInsert",{
			"editControl":this,
			"onClick":function(){
				var ctrl = this.getEditControl();
				var keys = ctrl.getKeys();
				if(!keys||!keys.id||keys.id=="null"){
					var n = ctrl.getNode().value;
					if(n&&n.length){
						var pm = (new Client_Controller()).getPublicMethod("insert_from_order");
						pm.setFieldValue("name",n);
						pm.run({
							"ok":function(resp){
								var m = resp.getModel("Client_Model");
								if(m.getNextRow()){
									ctrl.setKeys({"id":m.getFieldValue("id")});
									window.showNote("Создан новый клиент");
								}
							}
						})
					}
				}
			}
		});
	}

	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = ClientList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = Client_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Client_Controller();
	options.acModel = options.acModel || (new Client_Model());
	options.acPublicMethod = options.acController.getPublicMethod((options.acPublicMethodId||"complete"))
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name"),options.acModel.getField("inn")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ClientEdit.superclass.constructor.call(this,id,options);
}
extend(ClientEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

