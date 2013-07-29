# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
Geo = require('geojs')
EventEmitter = require('events').EventEmitter
get_time = ->(new Date).getTime()

reduce_path = (path, distance) ->
  if !isFinite(distance)
    throw new Error("bad distance")
  while path.length > 1
    segment = path[0].distanceTo(path[1])
    if distance < segment
      break
    distance -= segment
    path.shift()
  if path.length > 1
    path[0] = path[0].to(path[1], distance)
  path

class Fly
  constructor: (@event, loc, path, @speed)->
    path.unshift(loc)
    @path = path.map (p)->new Geo.Pos(p)
    # @time = get_time()
    #@update_position()
    @time = process.hrtime()
    @old_distance = 0
    return

  update_position: ->
    return @path[0] if @path.length == 1 # prevent infinite loop
    # time = get_time()
    time = process.hrtime(@time)
    distance = @speed * 1000 * (time[0] + time[1]*1e-9) - @old_distance
    old_length = @path.length
    @path = reduce_path(@path, distance)
    @old_distance += distance
    @event.emit('change:position', @path[0].toJSON())
    if @path.length == 1
      @event.move('stop')
    else
      if @path.length != old_length
        #console.log('Change direction to ', @direction())
        @event.emit('change:direction', @direction())
      @schedule_update()
    return @path[0]

  toJSON: ->
    waypoints: @path.map (e)->e.toJSON()
    speed: @speed
    # time: @time

  direction: ->
    src: @path[0].toJSON()
    heading: @path[0].bearing(@path[1])
    # time: @time
    speed: @speed

  schedule_update: ->
    clearTimeout(@timeout_id) if @timeout_id
    if @path.length > 1
      @timeout_id = setTimeout @update_position.bind(@), @path[0].distanceTo(@path[1]) / @speed
    else
      delete @timeout_id

  destroy: ->
    clearTimeout @timeout_id if @timeout_id?

class Stop
  constructor: (@event, loc)->
    @loc = new Geo.Pos(loc)
  update_position: -> @loc
  destroy: ->
  direction: ->
    @toJSON()
  toJSON: ->
    src: @loc.toJSON()
    waypoints: [@loc.toJSON()]

movement = (loc,speed)->
  self = new EventEmitter()
  move = new Stop(self, loc)
  self.force = ->
    move.update_position()
  self.move = (type, args...)->
    #console.log('Moves by ', type)
    loc = move.update_position()
    move.destroy()
    if type == 'fly'
      move = new Fly(self, loc, args..., speed[type])
    else if type == 'stop'
      move = new Stop(self, loc, args...)
    self.emit('change:movement', move.toJSON())
    self.emit('change:direction', move.direction())
    move.update_position()
  self.toJSON = -> move.toJSON()
  self.direction = -> move.direction()
  #self.move(arguments)
  return self

module.exports = movement

