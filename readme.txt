Map data:
running different historic extracts by using osmium to extract data from the planet history file.
note: we must use the .osh extensions for history files, otherwise osmium messes us locations

first filter copenhagen region:
osmium extract -b 12.3843,55.5694,12.7338,55.7766 history-latest.osh.pbf -o history-cph.osh.pbf --with-history

the create time extract:
osmium time-filter history-cph.osh.pbf 2013-01-01T00:00:00Z -o 2013.osm.pbf



OSRM:
git branch: cykelafstande, commit eab3461361ae7e913e37792dab2bcff21af62211
the branch doesn't use ferries
running locally on port 5000

extract and contract:
osrm-extract cph-2013.osm.pbf -p profiles/bicycle.lua
osrm-contract cph-2013.osrm

run server:
osrm-routed cph-2013.osrm



