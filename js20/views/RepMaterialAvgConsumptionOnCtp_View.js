/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepMaterialAvgConsumptionOnCtp_View(id,options){

	options = options || {};
	
	var contr = new RawMaterial_Controller();	
	options.publicMethod = contr.getPublicMethod("get_material_avg_cons_on_ctp");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "RepMaterialAvgConsumptionOnCtp";
	
	options.cmdMake = true;
	options.cmdPrint = false;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	this.m_periodCtrl = new EditPeriodDateShift(id+":filter-ctrl-period",{
		"valueFrom":(options.templateParams)? options.templateParams.date_from:DateHelper.getStartOfShift(DateHelper.time()),
		"valueTo":(options.templateParams)? options.templateParams.date_to:DateHelper.getEndOfShift(DateHelper.time()),
		"field":new FieldDateTime("date_time")
	});
	
	options.addElement = function(){
		this.addElement(
			new Control(id+":period","SPAN")
		);
	};
	
	options.filters = {
		"period":{
			"binding":new CommandBinding({
				"control":this.m_periodCtrl,
				"field":this.m_periodCtrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":this.m_periodCtrl.getControlFrom(),
					"field":this.m_periodCtrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":this.m_periodCtrl.getControlTo(),
					"field":this.m_periodCtrl.getField()
					}),
				"sign":"le"
				}
			]
		}
	};

	RepMaterialAvgConsumptionOnCtp_View.superclass.constructor.call(this, id, options);
	
}
extend(RepMaterialAvgConsumptionOnCtp_View,ViewReport);

RepMaterialAvgConsumptionOnCtp_View.prototype.fillParams = function(){	
	RepMaterialAvgConsumptionOnCtp_View.superclass.fillParams.call(this);
	
	
	this.getElement("period").setText(DateHelper.format(this.m_periodCtrl.getControlFrom().getValue(),"d/m/y H:i")+" - "+DateHelper.format(this.m_periodCtrl.getControlTo().getValue(),"d/m/y H:i"));
	
}

RepMaterialAvgConsumptionOnCtp_View.prototype.onGetReportData = function(respText){	

	RepMaterialAvgConsumptionOnCtp_View.superclass.onGetReportData.call(this,respText);
	
	var self = this;
	
	(new ButtonCmd(this.getId()+":printConcrTypeCost",{
		"title":"Печать таблицы стоимости м3"
		,"glyph":"glyphicon-print"
		,"onClick":function(){
			WindowPrint.show({content:document.getElementById(self.getId()+":gridConcrTypeCost").outerHTML});
		}
	})).toDOM(this.getNode());
	(new ButtonCmd(this.getId()+":exportConcrTypeCost",{
		"title":"Экспорт таблицы стоимости м3 в Excel"
		,"glyph":"glyphicon-save-file"
		,"onClick":function(){
			DOMHelper.tableToExcel(self.getId()+":gridBalanceCorrect","Стоимость м3", 'Стоимость_м3.xls');
		}
	})).toDOM(this.getNode());
	
	(new ButtonCmd(this.getId()+":printMatCost",{
		"title":"Печать таблицы стоимости материалов"
		,"glyph":"glyphicon-print"
		,"onClick":function(){
			WindowPrint.show({content:document.getElementById(self.getId()+":gridMatCost").outerHTML});
		}
	})).toDOM(this.getNode());
	(new ButtonCmd(this.getId()+":exportMatCost",{
		"title":"Экспорт таблицы стоимости материалов в Excel"
		,"glyph":"glyphicon-save-file"
		,"onClick":function(){
			DOMHelper.tableToExcel(self.getId()+":gridMatCost","Стоимость материалов", 'Стоимость_материалов.xls');
		}
	})).toDOM(this.getNode());


	(new ButtonCmd(this.getId()+":printMatQuant",{
		"title":"Печать таблицы объема материалов"
		,"glyph":"glyphicon-print"
		,"onClick":function(){
			WindowPrint.show({content:document.getElementById(self.getId()+":gridMatQuant").outerHTML});
		}
	})).toDOM(this.getNode());
	(new ButtonCmd(this.getId()+":exportMatQuant",{
		"title":"Экспорт таблицы объема материалов в Excel"
		,"glyph":"glyphicon-save-file"
		,"onClick":function(){
			DOMHelper.tableToExcel(self.getId()+":gridMatQuant","Объем материала", 'Объем_материала.xls');
		}
	})).toDOM(this.getNode());

	(new ButtonCmd(this.getId()+":printTot",{
		"title":"Печать итоговой таблицы"
		,"glyph":"glyphicon-print"
		,"onClick":function(){
			WindowPrint.show({content:document.getElementById(self.getId()+":gridTot").outerHTML});
		}
	})).toDOM(this.getNode());
	(new ButtonCmd(this.getId()+":exportTot",{
		"title":"Экспорт итоговой таблицы в Excel"
		,"glyph":"glyphicon-save-file"
		,"onClick":function(){
			DOMHelper.tableToExcel(self.getId()+":gridTot","Итоговая таблица", 'Итоговая_таблица.xls');
		}
	})).toDOM(this.getNode());


	(new ButtonCmd(this.getId()+":printBalanceCorrect",{
		"title":"Печать таблицы корректировки остатков материалов"
		,"glyph":"glyphicon-print"
		,"onClick":function(){
			WindowPrint.show({content:document.getElementById(self.getId()+":gridBalanceCorrect").outerHTML});
		}
	})).toDOM(this.getNode());
	(new ButtonCmd(this.getId()+":exportBalanceCorrect",{
		"title":"Экспорт таблицы корректировки остатков материалов в Excel"
		,"glyph":"glyphicon-save-file"
		,"onClick":function(){
			DOMHelper.tableToExcel(self.getId()+":gridBalanceCorrect","Корректировка остатков материалов", 'Корректировка_остатков_материалов.xls');
		}
	})).toDOM(this.getNode());
	
}
