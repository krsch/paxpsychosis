Backbone = require('backbone')
module.exports = mo = Backbone.Model.extend {
        icon: '/static/images/user.png'
        setPos: (pos)->
                loc = [pos[0] ? pos.lat, pos[1] ? pos.lon ? pos.lng]
                throw "Bad position" if undefined in pos
                @set('loc', loc)
                latlng = @get('latlng')
                [latlng.lat, latlng.lng] = loc
                @redraw
        redraw: ->
                @get('marker').setLanLng(@get('pos'))
        initialize: ->
                unless @has('loc')
                        @set('loc', [0,0])
                @set('latlng', latlng = new L.LatLng(@get('loc')...))
                @set('marker', marker = new L.Marker(latlng, icon: new L.Icon(@get('icon')) ))
                osm.addLayer(marker)
        remove: ->
                osm.removeLayer(marker)
}
