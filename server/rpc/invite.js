// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
var Invite = require('../models/invite');

exports.actions = function(req, res, ss){
        req.use('pc.load', req);

        return {
                newi: function(){
                        var r = new Invite({by: req.pc._id});
                        console.log(r);
                        r.save(res);
                }
        };
};
