Geo = require('geojs')

Geo.Pos.prototype.toJSON = -> {lat: @lat, lon: @lon}
