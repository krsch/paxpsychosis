Pc = require('../models/pc')

exports.get = (req)->
  req.use('session')
  req.use('auth.authenticated')
  (req, res, next) ->
    if req.session && req.session.pc_id
      Pc.by_id req.session.pc_id, (err, pc)->
        if err
          console.error(err)
          return next(err)
        req.pc = pc
        next()
    else
      Pc.by_user req.session.userId, (err, pc)->
        if err
          console.error(err)
          return next(err)
        req.session.pc_id = pc._id
        req.pc = pc
        cache.pc[pc._id] ?= pc
        next()
