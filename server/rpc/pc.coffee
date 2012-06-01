Geo = require('geojs')
exports.actions = (req,res,ss) ->
  req.use('session')
  req.use('auth.authenticated')

  get: ->
    if req.session.pc
      res(req.session.pc)
      return
    userid = req.session.userId
    pc = require('./../models/pc')
    pc.findOne {userId: userid}, (err,doc)->
      if err
        console.log(err)
        res(null)
      else
        req.session.pc = doc
        req.session.pc_id = doc._id
        req.session.save()
        cache.pc[doc._id] = doc
        res(doc)
  move: (type, dst) ->
    if type != 'fly'
      res(null)
    pc = cache.pc[req.session.pc_id]
    if pc.updatePos
      pc.updatePos(ss)
    pc.movement ?= {}
    pc.pos ?= new Geo.Pos(pc.loc[0], pc.loc[1])
    dst_pos = new Geo.Pos(dst[0], dst[1])
    pc.movement.way = new Geo.Line([pc.pos, dst_pos])
    # FIXME: add multisegment support
    distance = pc.movement.way.distance().total
    pc.movement.speed ?= 0.005 / 1000
    pc.movement.start = (new Date).getTime()
    time = distance / pc.movement.speed
    pc.updatePos ?= updatePos
    setTimeout((-> pc.updatePos(ss)), time)
    res {
      waypoints: pc.movement.way.positions
      speed: pc.movement.speed
    }

updatePos = (ss)->
  time = (new Date).getTime() - @movement.start
  distance = time * @movement.speed
  @pos = @movement.way.traverse(distance)
  @loc[0] = @pos.lat
  @loc[1] = @pos.lon
  
  Pc = require('./../models/pc')
  Pc.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->
    if num != 1 || err
      console.log err
  ss.publish.user(@userId, 'pcPosition', @loc)
