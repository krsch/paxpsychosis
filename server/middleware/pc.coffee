# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
Pc = require('../models/pc')
User = require('../models/user')

exports.load = (req)->
  req.use('session')
  req.use('auth.authenticated')
  (req, res, next) ->
    req.session.pc_id ||= User.getPc(req.session.userId)
    if !req.session.pc_id
            res('pc not selected')
    else
      Pc.by_id req.session.pc_id, (err, pc)->
        if err
          console.error(err)
          res(err.message)
          return
        req.pc = pc
        next()
      # Pc.by_user req.session.userId, (err, pc)->
      #   if err
      #     console.error(err)
      #     res(err.message)
      #     return
      #   req.session.pc_id = pc._id
      #   req.session.save()
      #   req.pc = pc
      #   next()
