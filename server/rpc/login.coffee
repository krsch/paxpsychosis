exports.actions = (req,res,ss) ->
  req.use('session')
  
  login: (username,pass) ->
    User = require('./../models/user')
    User.findOne {login: username, password: pass}, (err,doc)->
      if err
        res(false)
      else if doc
        req.session.userId = doc._id
        req.session.save()
        res(true)
      else
        console.error("Unknown error in mongoose. Both doc and err are null. Login is #{username}")
        res(false)
  
  isLoggedin: ->
    res(req.session && req.session.userId)
