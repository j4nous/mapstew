.PHONY: tiles
.ONESHELL:

all: tiles localhost

tiles: data/taiwan-latest.osm.pbf 
	tilemaker $< --output=tiles/ --config resources/config-mapstew.json --process resources/process-mapstew.lua
	jq '.tiles = ["<URL_PREFIX>/tiles/{z}/{x}/{y}.pbf"]' tiles/metadata.json >tiles/metadata.json.bak
	mv tiles/metadata.json.bak tiles/metadata.json

clean:
	rm -rf tiles/ data/ && git reset --hard

data/taiwan-latest.osm.pbf:
	mkdir -p data/
	curl -Lo $@ http://download.geofabrik.de/asia/taiwan-latest.osm.pbf

data/taipei-latest.osm.pbf: data/taiwan-latest.osm.pbf
	osmconvert $< -b=121.346,24.926,121.676,25.209 --drop-broken-refs -o=$@

localhost:
	ls *html tiles/metadata.json styles/* | xargs sed -i 's#<URL_PREFIX>#http://localhost:8000#'
	# This script launch a simple server which enables CORS, so can co-works with Maputnik to tune styles
	scripts/simple_cors_server.py &
	pid=$$!
	xdg-open http://localhost:8000
	kill -9 $$pid
