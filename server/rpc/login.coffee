exports.actions = (req,res,ss) ->
  req.use('session')
  
  login: (username,pass) ->
    User = require('./../models/user')
    User.findOne {login: username, password: pass}, (err,doc)->
      if err
        res(false)
      else
        req.session.userId = doc._id
        req.session.save()
        res(true)
  
  isLoggedin: ->
    res(req.session && req.session.userId)
