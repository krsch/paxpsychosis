exports.actions = (req,res,ss) ->
  req.use('session')
  req.use('auth.authenticated')

  get: ->
    userid = req.session.userId
    pc = require('./../models/pc')
    pc.findOne {userId: userid}, (err,doc)->
      if err
        console.log(err)
        res(null)
      else
        res(doc)
