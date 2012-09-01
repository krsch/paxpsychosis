login = require('./login')
init = require('./init')
exports.startup = ->
  login.login (err,ok) ->
    # TODO: check for errors
    init.loadMap()

exports.startup()

