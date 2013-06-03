# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Example request middleware

User = require('../models/user')
# Only let a request through if the session has been authenticated
exports.authenticated = ->
  (req, res, next) ->
    req.session.userId ||= User.by_sid(req.sessionId);
    if req.session && req.session.userId?
      next()
    else
            res('Not logged in')
            # console.log(req.session);
            # User.find {session: req.sessionId}, (err,doc)->
            #         console.log(err) if err
            #         if !err && doc?
            #                 req.session.setUserId doc._id
            #                 next()
            #         else
            #           res('Not logged in')

