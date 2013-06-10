// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
var Invite = require('../../models/invite');

exports.actions = function(req, res, ss){
        req.use('session');
        req.use('auth.admin');

        return {
                create: function(comment){
                        var r = new Invite({by: req.session.userId, comment: comment, created_at: Date.now()});
                        r.save(function(err, doc){
                                console.log(doc);
                                res(err);
                                ss.publish.channel('invites', 'invite:add', doc);
                        });
                },
                list: function(){
                        Invite.find({}, function(err, docs){
                                res(null, docs);
                        });
                        req.session.channel.subscribe('invites');
                }
        };
};
