# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
MovingObject = require('./moving')

module.exports = class Pc extends MovingObject
  icon: '/images/x2.png'
  initialize: ->
    super
    @set('dstMarker', new L.CircleMarker(new L.LatLng(0,0)))
    @set('path', new L.Polyline([], {}))
    @on 'change:movement', ->
      dstMarker = @get('dstMarker')
      path = @get('path')
      if @has('movement')
        m = @get('movement')
        if m.animate
          dst = @get('movement').waypoints[1]
          dstMarker.setLatLng(dst)
          osm.addLayer(dstMarker) unless osm.hasLayer(dstMarker)
          path.setLatLngs(@get('movement').waypoints)
          osm.addLayer(path) unless osm.hasLayer(path)
        else
          osm.removeLayer(dstMarker) if osm.hasLayer(dstMarker)
          osm.removeLayer(path) if osm.hasLayer(path)
      else
        osm.removeLayer(dstMarker) if osm.hasLayer(dstMarker)
        osm.removeLayer(path) if osm.hasLayer(path)
    @on 'change:loc', ->
      if @has('movement') and @get('movement').animate
        @get('path').spliceLatLngs(0, 1, @get('loc'))
  @load = (fn)->
    ss.rpc 'pc.pc.get', (err,pc_data)->
      if err
        fn(err)
      else
        pc = new Pc(pc_data)
        look_around()
        fn(null, pc)

ss.event.on 'pcPosition', (pos)->
  return unless pc
  pc.setPosition(pos)
  pc.unset('movement') if pc.has('movement')

ss.event.on 'pcMove', (movement)->
  return unless pc
  console.log('I move', movement)
  pc.startMovement(movement)

look_around = ->
  ss.rpc 'pc.pc.lookAround', (err, new_people)->
    if err
      console.error(err)
      return
    return if new_people == true
    window.people ?= {}
    new_people.forEach (e)->
      if e._id of people
        #TODO add support for other fields
        people[e._id].set('loc', e.loc)
      else
        people[e._id] = new Moving(e)

setInterval look_around, 10000

