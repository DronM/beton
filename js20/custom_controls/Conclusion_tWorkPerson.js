/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends EditXML
 * @requires core/extend.js
 * @requires controls/EditXML.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Conclusion_tWorkPerson(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new EditString(id+":FamilyName",{
			,"required":true
			,"length":"100"
			,"labelCaption":"Фамилия:"
			,"title":"Фамилия сотрудника"
			,"regExpression":/^[-а-яА-ЯёЁ\s]+$/
		}));								
	
		this.addElement(new EditString(id+":FirstName",{
			,"required":true
			,"length":"100"
			,"labelCaption":"Имя:"
			,"title":"Имя сотрудника"
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
	
		this.addElement(new EditString(id+":SecondName",{
			,"required":false
			,"length":"50"
			,"labelCaption":"Отчество:"
			,"title":"Отчество сотрудника"
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
	
		this.addElement(new EditString(id+":Position",{
			,"required":true
			,"length":"500"
			,"labelCaption":"Должность:"
			,"title":"Должность сотрудника"
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
	}
	
	Conclusion_tWorkPerson.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tWorkPerson,EditModalDialogXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

