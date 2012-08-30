Geo = require('geojs')
Pc = require('../models/pc')
exports.actions = (req,res,ss) ->
  req.use('session')
  req.use('auth.authenticated')

  get: ->
    if req.session.pc_id
      res(null,cache.pc[req.session.pc_id])
      return
    userid = req.session.userId
    Pc.findOne {userId: userid}, (err,doc)->
      if err
        console.log(err)
        res(err)
      else
        req.session.pc_id = doc._id
        req.session.save()
        cache.pc[doc._id] = doc
        res(null,doc)
  move: (type, dst) ->
    Pc.by_id req.session.pc_id, (err,pc) ->
      return res(err) if err
      unless type of pc.speed
        return res(new Error('Wrong move type'),null)
      pc.move(type, dst)
      res null, {
        waypoints: pc.movement.way.positions.map (p) -> [p.lat, p.lon]
        speed: pc.movement.speed
        distance: pc.movement.way.distance().total
        time: pc.movement.start
      }
  lookAround: ->
    Pc.by_id req.session.pc_id, (err, pc) ->
      return res(err) if err
      console.error("Couldn't load pc", req.session.pc_id) unless pc
      pc.updatePos()
      Pc.find {loc: {$within: $center: [pc.loc, m2deg(200)]}, _id: $ne: pc._id }, (err, near)->
        near.forEach (e)->
          if e._id of cache.pc
            cache.pc[e._id].updatePos()
        Pc.find {loc: {$within: $center: [pc.loc, m2deg(100)]}, _id: $ne: pc._id }, (err, near)->
          console.log(err) if err
          return res(err) if err
          pc_export = near.map (e)->{_id: e._id, loc: e.loc, type: 'person'}
          pc.sees_only pc_export
          near.forEach (e)->e.seen_by pc
          return res(null, true)

m2deg = (m)->m/6321000/3.1415926*180
