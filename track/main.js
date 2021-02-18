var map = new ol.Map({
	layers: [
		new ol.layer.Tile({
		source: new ol.source.OSM()
		})
	],
	target: 'map',
	view: new ol.View({
		center: [0, 0],
		zoom: 2
	})
});

var appSrv = new AppSrv({
	host: '178.46.157.185',
	port: 1337,
	appId: 'beton'
});

appSrv.connect();
