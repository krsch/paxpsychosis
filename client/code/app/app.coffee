# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
require('./common')
login = require('./login')
init = require('./init')
exports.startup = ->
  login.login (err,ok) ->
    # TODO: check for errors
    init.loadMap()

exports.startup()

