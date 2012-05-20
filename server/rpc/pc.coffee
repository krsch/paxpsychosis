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
        req.session.save()
        res(doc)
  move: (dst) ->
    pc = req.session.pc
    pc.movement ?= {}
    pc.movement.dst = dst
    pc.movement.speed ?= 0.0001
    pc.movePc = movePc
    unless pc.interval_id
      pc.interval_id = setInterval((-> pc.movePc(ss)), 1000)
    req.session.save()

movePc = (ss)->
  dir = [0, 0]
  dir[0] = @movement.dst[0] - @loc[0]
  dir[1] = @movement.dst[1] - @loc[1]
  #console.log "Difference #{dir} from #{@loc} to #{@movement.dst}"
  distance = Math.sqrt(dir[0]*dir[0] + dir[1]*dir[1])
  if distance > @movement.speed
    @loc[0] = @loc[0] + dir[0]*@movement.speed/distance
    @loc[1] = @loc[1] + dir[1]*@movement.speed/distance
  else
    @loc = @movement.dst
    clearInterval @interval_id
  Pc = require('./../models/pc')
  Pc.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->
    if num != 1 || err
      console.log err
  ss.publish.user(@userId, 'pcPosition', @loc)
