# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
MapObject = require('./map_object')
_ = require('underscore')

heading = (l1, l2)->
  p1 = new geo.Point(l1.lat, l1.lng)
  p2 = new geo.Point(l2.lat, l2.lng)
  geo.math.heading(p1,p2)

module.exports = class MovingObject extends MapObject
  updatePosition: =>
    return unless @has('movement')
    m = @get('movement')
    duration = (new Date).getTime() - m.startTime
    distance = 1000*duration * m.speed
    pos = geo.math.destination(m.start_pos, heading:m.heading, distance:distance)
    @setPosition([pos.lat(), pos.lng()])
    if m.animate
      if !m.distance? || distance < m.distance
        requestAnimationFrame(@updatePosition)
      else
        m.animate = false
        @trigger('change:movement')

  startMovement: (movement)->
    if movement
      movement.animate = true
      @setMovement(movement)
    else
      @get('movement').animate = true
      @trigger('change:movement')
      requestAnimationFrame(@updatePosition)

  setMovement: (movement)->
    if movement.waypoints
      @setPosition(movement.waypoints[0])
      if movement.waypoints.length == 1
        @unset('movement')
        return
      movement.waypoints = movement.waypoints.map ({lat, lon}) -> new L.LatLng(lat,lon)
      movement.distance = movement.waypoints[0].distanceTo(movement.waypoints[1])
      movement.heading = heading(movement.waypoints[0..1]...)
      movement.start_pos = new geo.Point(movement.waypoints[0].lat, movement.waypoints[0].lng)
    else
      @setPosition movement.src
      movement.start_pos = new geo.Point(movement.src.lat, movement.src.lon)
    movement.startTime = (new Date).getTime()
    movement.animate ?= false
    @set('movement', movement)
    #return if movement.distance? == 0
    if movement.animate
      requestAnimationFrame(@updatePosition)
  remove: ->
    @unset('movement')
    super()

ss.event.on 'you see', (e)->
  window.people ?= {}
  console.log('I see', e)
  if e._id of people
    #TODO add support for other fields
    people[e._id].setPosition(e.loc)
  else
    people[e._id] = new MovingObject(e)
  if e.movement
    people[e._id].startMovement(e.movement)
  else if people[e._id].has('movement')
    people[e._id].unset('movement')

ss.event.on 'you lost', (pcs)->
  window.people ?= {}
  pcs.forEach (e)->
    if e._id of people
      people[e._id].remove()
      delete people[e._id]
