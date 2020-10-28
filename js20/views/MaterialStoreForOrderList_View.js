/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends Control
 * @requires core/extend.js
 * @requires controls/Control.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function MaterialStoreForOrderList_View(id,options){
	options = options || {};	
	
	this.m_listView = options.listView;
	this.setData(options.model);
	options.templateOptions = this.getTemplateOptions();
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.PIC_H = this.PIC_H;
	options.templateOptions.CONT_H = this.CONT_H;
	options.templateOptions.PIC_W = this.PIC_W;
	
	MaterialStoreForOrderList_View.superclass.constructor.call(this,id,"TEMPLATE",options);
	
	this.fillStores();
}
//ViewObjectAjx,ViewAjxList
extend(MaterialStoreForOrderList_View,Control);

MaterialStoreForOrderList_View.prototype.PIC_H = 60;
MaterialStoreForOrderList_View.prototype.PIC_W = 50;
MaterialStoreForOrderList_View.prototype.CONT_H = 60;

MaterialStoreForOrderList_View.prototype.setData = function(modelStores){
	
	/** !!!перересовка только с случае, если изменился состав бункеров, иначе просто отрисовка наполненности!!!
	 * т.е. либо m_stores еще не инициализирована, либо надо проверять новый набор данных...
	 */
	var is_init = (this.m_stores==undefined);	
	var redraw = false;
	
	if(!is_init){
		var store_cnt = 0;
		var store_id;
		while(modelStores.getNextRow()){
			store_id = modelStores.getFieldValue("id"); 
			if(!this.m_stores["store_"+store_id]
			||!document.getElementById("store_canvas_"+store_id)
			){
				redraw = true;
			}
			else if(this.m_stores["store_"+store_id]){
				
				this.m_stores["store_"+store_id].balance = parseFloat(modelStores.getFieldValue("balance"),10);
				if(isNaN(this.m_stores["store_"+store_id].balance)){
					this.m_stores["store_"+store_id].balance = 0;
				}
			}
			store_cnt++;
		}
		if(!redraw && (modelStores.getRowCount()!=store_cnt)){
			redraw = true;
		}
		modelStores.reset();
	}	
	
	if(is_init || redraw){
		this.m_stores = [];//reinitialize
		var templ_opts = {
			"productionSites":[]
		};
		var prod_site,cur_prod_site;
		while(modelStores.getNextRow()){
			cur_prod_site = modelStores.getFieldValue("production_sites_ref");
			
			var s_name = modelStores.getFieldValue("name");
			var s_id = cur_prod_site.getKey("id");//modelStores.getFieldValue("id");
		
			if(!prod_site || prod_site.productionSiteId!=cur_prod_site.getKey("id")){
				prod_site = {
					"productionSiteName":cur_prod_site.getDescr(),
					"productionSiteId":cur_prod_site.getKey("id"),
					"stores":[]
				};
				templ_opts.productionSites.push(prod_site);
			}
			prod_site.stores.push({
				"storeName":s_name,
				"storeId":s_id
			});

			this.m_stores["store_"+s_id] = {
				"name":s_name,
				"id":s_id,
				"balance":modelStores.getFieldValue("balance"),
				"load_capacity":modelStores.getFieldValue("load_capacity"),
				"material_id":modelStores.getFieldValue("material_id")
			}
		}
		console.log("templ_opts=")
		console.log(templ_opts)
		this.setTemplateOptions(templ_opts);		
	}
		
	if(redraw){
		this.setTemplate(window.getApp().getTemplate("MaterialStoreForOrderList_View"));
	}
	
	if(!is_init){
		this.fillStores();
	}
}

MaterialStoreForOrderList_View.prototype.fillStores = function(){	

	for(var store_id in this.m_stores){
		var store_n = document.getElementById("store_canvas_"+this.m_stores[store_id].id);
		var store_cont_n = document.getElementById("store_cont_"+this.m_stores[store_id].id);
		if(store_n && store_cont_n){
			var percent = (!this.m_stores[store_id].load_capacity
					||isNaN(this.m_stores[store_id].load_capacity)
					||!this.m_stores[store_id].balance
					||isNaN(this.m_stores[store_id].balance)
				)?
				0:Math.floor((this.m_stores[store_id].balance / this.m_stores[store_id].load_capacity * 100));
			if(percent>100){
				percent=100;
			}
			else if(isNaN(percent)){
				percent = 0;
			}
			
			store_n.title = "Остаток:"+((this.m_stores[store_id].balance && !isNaN(this.m_stores[store_id].balance))? this.m_stores[store_id].balance:0);//+", двойной клик для обнуления."
			console.log("this.m_stores[store_id].material_id="+this.m_stores[store_id].material_id)
			console.log("this.m_stores[store_id].id="+this.m_stores[store_id].id)
			if(this.m_stores[store_id].load_percent!=percent){
				store_n.setAttribute("store_id",this.m_stores[store_id].id);				
				this.m_stores[store_id].load_percent = percent;
				this.drawStore(store_n,store_cont_n,0,0,percent);
				EventHelper.add(
					store_n,
					"dblclick",
					(function(materialId,materialDescr,productionSiteId){
						return function(e){
							window.getApp().materialQuantCorrection({
								"material_id":new FieldInt("material_id",{"value":materialId})
								,"material_descr":new FieldString("material_descr",{"value":materialDescr})
								//,"production_sites_ref":new RefType({"keys":{"id":productionSiteId}})
								,"production_site_id":productionSiteId
							});
						}
					})(this.m_stores[store_id].material_id,this.m_stores[store_id]["name"],this.m_stores[store_id].id)
				);
			}
		}
	}
}

MaterialStoreForOrderList_View.prototype.drawStore = function(storeNode,storeContNode,posLeft,posTop,fillPercent){
	var store_height = this.PIC_H;//100
	var store_width = this.PIC_W;//100
	var fill_tolerance = 0;

	var cx = storeNode.getContext("2d");		
	cx.clearRect(posLeft, posTop,store_width,store_height+store_height);
	cx.lineWidth = "2";
	cx.beginPath();
	cx.moveTo(posLeft, posTop);
	cx.lineTo(posLeft, posTop + store_height);
	cx.lineTo(posLeft  + store_width , posTop + store_height);
	cx.lineTo(posLeft  + store_width , posTop);
	cx.lineTo(posLeft , posTop);
	cx.stroke(); 
	
	//filling
	var fill_h = Math.floor( store_height * fillPercent / 100) - fill_tolerance;
	var fill_top = posTop + store_height - fill_h;
	cx.fillStyle = "grey";
	cx.lineWidth = "0.5";
	cx.beginPath();
	cx.moveTo(posLeft + fill_tolerance, fill_top + fill_tolerance);
	cx.lineTo(posLeft + fill_tolerance, posTop + store_height - fill_tolerance);
	cx.lineTo(posLeft + store_width, posTop + store_height - fill_tolerance);
	cx.lineTo(posLeft + store_width, fill_top + fill_tolerance);
	cx.fill();
		
	DOMHelper.delAllChildren(storeContNode);
	
	//text percent
	DOMHelper.setText(storeContNode,fillPercent+"%");
	storeContNode.style = "position:relative;top:-"+( (store_height)/2+100)+"px;left:5px";
}

