MovingObject = require('./moving')

class Pc extends MovingObject
        initialize: ->
                super
                @set('dstMarker', new L.CircleMarker(new L.LatLng(0,0)))
                @on 'change:movement', ->
                        m = @get('movement')
                        dstMarker = @get('dstMarker')
                        if m.animate
                          dst = @get('movement').waypoints[1]
                          dstMarker.setLatLng(new L.LatLng(dst...))
                          osm.addLayer(dstMarker) unless osm.hasLayer(dstMarker)
                        else
                          osm.removeLayer(dstMarker) if osm.hasLayer(dstMarker)

module.exports = Pc
