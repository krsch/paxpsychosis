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
      #pc = cache.pc[req.session.pc_id]
      pc.move(type, dst)
      res null, {
        waypoints: pc.movement.way.positions.map (p) -> [p.lat, p.lon]
        speed: pc.movement.speed
        distance: pc.movement.way.distance().total
        time: pc.movement.start
      }

