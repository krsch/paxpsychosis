# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
Backbone = require('backbone')
ss = require('socketstream')

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
    ss.rpc 'pc.pc.observe', @get('_id'), (obj)=>
            interfaces = require('../interfaces')
            @set('actions', [])
            for i of obj.interfaces
                    interfaces[i].call(this, obj.interfaces[i])
    if @has('loc')
      loc = @get('loc')
      @set('loc', [loc.lat, loc.lon]) unless @get('loc') instanceof Array
    else
      @set('loc', [0,0])
    @set('marker', marker = new L.Marker(@get('loc'), icon: new L.Icon(iconUrl: @icon, iconSize: [32, 32]) ))
    marker.on 'click', =>
            popup = require('../ui/actions')
            popup(this)
    osm.addLayer(marker)
  remove: ->
    osm.removeLayer(@get('marker'))
