// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
var chat_id = 0;
var Pc = require('../../models/pc');
exports.actions = function(req, res, ss) {
        req.use('pc.load', req);
        return {
                start: function(id) {
                        if (req.session.talk[id]) {
                                res(null, req.session.talk[id]);
                        } else {
                                req.session.talk[id] = {
                                        dialog: null
                                };
                        }
                },
                'start chat': function(pc_id) {
                        if (!pc_id) { return res('Bad PC id'); }
                        console.log('staring chat with '+ pc_id);
                        Pc.by_id(pc_id, function(err, talker){
                                if (err) { console.error(err); return res(err); }
                                console.log('staring chat with '+ talker.name);
                                req.pc.chats = req.pc.chats || {};
                                req.pc.chats[pc_id] = chat_id++;
                                req.session.channel.subscribe('chat:'+chat_id);
                                // talker.subscribe('chat:'+chat_id);
                                res(null, chat_id);
                        });
                },
                say: function(chat_id, message) {
                        var m = {message: message, chat: chat_id, from: req.pc._id};
                        ss.publish.channel('chat:'+chat_id, 'chat:message', m);
                        res(null);
                }
        };
};
