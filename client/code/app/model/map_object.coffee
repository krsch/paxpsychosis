# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
Backbone = require('backbone')

module.exports = class MapObject extends Backbone.Model
  icon: '/images/x1.png'
  setPosition: (pos)->
    loc = [pos[0] ? pos.lat, pos[1] ? pos.lon ? pos.lng]
    throw "Bad position" if undefined in pos
    @set('loc', loc)
    @redraw()
  redraw: ->
    @get('marker').setLatLng(@get('loc'))
  initialize: ->
    super
    if @has('loc')
      loc = @get('loc')
      @set('loc', [loc.lat, loc.lon]) unless @get('loc') instanceof Array
    else
      @set('loc', [0,0])
    @set('marker', marker = new L.Marker(@get('loc'), icon: new L.Icon(iconUrl: @icon, iconSize: [32, 32]) ))
    osm.addLayer(marker)
  remove: ->
    osm.removeLayer(@get('marker'))
