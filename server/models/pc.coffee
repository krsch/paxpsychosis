# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
mongoose = require 'mongoose'
$ = require('interlude')
deepEqual = require('deep-equal')
_ = require('underscore')
Geo = require('geojs')
ss = require('socketstream').api
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
movement = require('./movement')
pc_schema = new Schema {
  name: String
  factionId: ObjectId
  userId: {type: ObjectId, index: true}
  speed: { fly: {type: Number, default: 5e-6} }
  loc: {type: [Number], index: "2d"}
  skills: Schema.Types.Mixed
}

log_error = (err)->(console.error(err) if err)

class Pc
  constructor: (@doc)->
    if @doc._id of cache.pc
      throw new Error("PC document not loaded into cache but trying to be created")
    @_id = @doc._id
    @around = []
    @loc = new Geo.Pos({lon: @doc.loc[0], lat: @doc.loc[1]})
    @movement = movement(@loc, @doc.speed)
    @movement.on 'change:movement', (movement)=>
      @publish 'pcMove', movement
    @movement.on 'change:direction', (movement)=>
      @notify_movement(movement)
    @movement.on 'change:position', (loc)=>
      @loc = new Geo.Pos(loc)
      @doc.loc = [loc.lon, loc.lat]
      model.update {_id: @_id}, {$set: {loc: @doc.loc}}, log_error
      look_around(@)
  @adopt: (doc)->
    if doc._id of cache.pc
      throw new Error("PC document not loaded into cache but trying to be created")
      cache.pc[doc._id]
    else
      cache.pc[doc._id] = new Pc(doc)
  @create: (params, cb)->
          model.create params, (err, doc)->
                  if err
                          cb(err)
                  else
                          cb(null, Pc.adopt(doc))
  publish: (topic, message)->
    # ss.publish.user(@doc.userId, topic, message)
    ss.publish.channel('pc:'+@doc._id, topic, message)
  updatePos: ->
    @movement.force()
  move: ->
    @movement.move(arguments...)
  notify_movement: (m)->
    @around.forEach (pc)=>
      by_id pc, (err, pc)=>
        throw new Error(err) if err
        pc.see(@, m)
  notify_chat: (chat)->
          @publish('chat:new', {id: chat_id, talkers: chat.pcs.map((pc)->pc._id)})
  @jsonify: (doc)->
    skills = {}
    for cat of doc.skills
      skills[cat] = doc.skills[cat].map (skill)->{name: skill.name, value: skillLevel2Value(skill.level)}
    {
      _id: doc._id
      name: doc.name
      loc: {lon: doc.loc[0], lat: doc.loc[1]}
      skills: skills
    }
  toJSON: ->
          Pc.jsonify(@doc)
  see: (pc, m)->
    if pc._id == @_id
              console.log(pc._id, @_id, @around)
    @publish 'you see',
      _id: pc._id
      loc: {lat: pc.doc.loc[1], lon: pc.doc.loc[0]}
      movement: m ? pc.movement.direction()
  lost: (pc)->
    @publish 'you lost', _id: pc._id


look_around = (pc)->
  return

by_user = (userId, cb) ->
  model.findOne {userId}, (err, doc)->
    return cb(arguments...) if err
    return cb('not found') unless doc?
    cb(null, if doc._id of cache.pc
        cache.pc[doc._id]
      else
        Pc.adopt(doc))
by_id = (_id, cb) ->
  if _id of cache.pc
        cb(null, cache.pc[_id])
  else
    model.findById _id, (err,doc)->
      return cb(arguments) if err
      return cb('Not found') unless doc
      if _id of cache.pc
        cache.pc[_id]
      else
        cb(null, Pc.adopt(doc))

names_by_user = (userId, cb)->
        model.find {userId}, (err, docs)->
                return cb(err) if err
                cb(null, docs.map Pc.jsonify)

Pc.prototype.sees_only = (pc)->
  pc_ids = @around.map (e)->{_id: e}
  equals = (a,b)-> String(a._id) == String(b._id)
  new_pcs = $.differenceBy(equals, pc, pc_ids)
  old_pcs = $.differenceBy(equals, pc_ids, pc)
  old_pcs.forEach (pc)=>
    by_id pc._id, (err, pc)=>
      throw err if err
      pc.lost(@)
      @lost(pc)
  new_pcs.forEach (pc)=>
    by_id pc._id, (err, pc)=>
      throw err if err
      pc.see(@)
      @see(pc)
  @around = pc.map (e)->e._id

skillLevel2Value = (level)->
  if level < 0
    'лох'
  else if level < 5
    'нуб'
  else if level < 10
    'норм'
  else if level < 15
    'крут'
  else 'супер'

model = mongoose.model('PC', pc_schema)
module.exports =
  model: model
  by_id: by_id
  by_user: by_user
  create: Pc.create
  jsonify: Pc.jsonify
  json_by_user: names_by_user
  find: (query, cb)->
    model.find query, (err, docs)->
      cb(arguments) if err
      cb null, docs.map (doc)->
        if cache.pc[doc._id]
          cache.pc[doc._id]
        else
          Pc.adopt(doc)
