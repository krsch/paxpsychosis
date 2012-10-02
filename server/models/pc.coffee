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
  userId: {type: ObjectId, unique: true}
  speed: { fly: {type: Number, default: 5e-6} }
  loc: {type: [Number], index: "2d"}
  skills: [{name: String, value: Number}]
}

log_error = (err)->(console.error(err) if err)

class Pc
  constructor: (@doc)->
    if @doc._id of cache.pc
      throw new Error("PC document not loaded into cache but trying to be created")
    @_id = @doc._id
    @around = []
    loc = {lon: @doc.loc[0], lat: @doc.loc[1]}
    @movement = movement(loc, @doc.speed)
    @movement.on 'change:movement', (movement)=>
      @publish 'pcMove', movement
    @movement.on 'change:direction', (movement)=>
      @notify_movement(movement)
    @movement.on 'change:position', (loc)=>
      @doc.loc = [loc.lon, loc.lat]
      #loc = {lon: @doc.loc[0], lat: @doc.loc[1]}
      model.update {_id: @_id}, {$set: {loc: @doc.loc}}, log_error
      look_around(@)
  @create: (doc)->
    if doc._id of cache.pc
      throw new Error("PC document not loaded into cache but trying to be created")
      cache.pc[doc._id]
    else
      cache.pc[doc._id] = new Pc(doc)
  publish: (topic, message)->
    ss.publish.user(@doc.userId, topic, message)
  updatePos: ->
    @movement.force()
  move: ->
    @movement.move(arguments...)
  notify_movement: (m)->
    @around.forEach (pc)=>
      by_id pc, (err, pc)=>
        throw new Error(err) if err
        pc.see(@, m)
  toJSON: ->
    {
      name: @doc.name
      loc: {lon: @doc.loc[0], lat: @doc.loc[1]}
      skills: @doc.skills.map (skill)->{name: skill.name, value: skillLevel2Value(skill.level)}
    }
  see: (pc, m)->
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
    cb(null, if doc._id of cache.pc
        cache.pc[doc._id]
      else
        Pc.create(doc))
by_id = (_id, cb) ->
  if _id of cache.pc
    cb(null, cache.pc[_id])
  else
    model.findOne {_id}, (err,doc)->
      return cb(arguments) if err
      if _id of cache.pc
        cache.pc[_id]
      else
        cb(null, Pc.create(doc))

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
  find: (query, cb)->
    model.find query, (err, docs)->
      cb(arguments) if err
      cb null, docs.map (doc)->
        if cache.pc[doc._id]
          cache.pc[doc._id]
        else
          Pc.create(doc)
