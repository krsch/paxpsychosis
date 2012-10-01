Pc = require('../models/pc')

exports.load = (req)->
  req.use('session')
  req.use('auth.authenticated')
  (req, res, next) ->
    if req.session && req.session.pc_id
      Pc.by_id req.session.pc_id, (err, pc)->
        if err
          console.error(err)
          next(err.message)
          return
        req.pc = pc
        next()
    else
      Pc.by_user req.session.userId, (err, pc)->
        if err
          console.error(err)
          next(err.message)
          return
        req.session.pc_id = pc._id
        req.session.save()
        req.pc = pc
        next()
