# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
exports.actions = (req,res,ss) ->
  req.use('session')
  
  login: (username,pass) ->
    User = require('./../models/user')
    User.findOne {login: username, password: pass}, (err,doc)->
      if err
        res('Wrong username or password')
      else if doc
        req.session.userId = doc._id
        req.session.save()
        res(null, true)
      else
        console.error("Unknown error in mongoose. Both doc and err are null. Login is #{username}")
        res('Bad error')
  
  isLoggedin: ->
    res(null, req.session && req.session.userId)

  logout: ->
    delete req.session.userId
    delete req.session.pc_id
    req.session.save()
    res(null)
