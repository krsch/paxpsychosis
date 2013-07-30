// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
var chat_id = 0;
var Pc = require('../../models/pc');
var Chat = require('../../models/chat');
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
                        Pc.by_id(pc_id, function(err, talker){
                                if (err) { console.error(err); return res(err); }
                                var chat = new Chat();
                                chat.add(req.pc).add(talker);
                                talker.notify_chat(chat);
                                res(null, chat_id);
                        });
                },
                say: function(chat_id, message) {
                        if (!req.pc.chats || !req.pc.chats[chat_id]) {
                                return res('Chat not found');
                        }
                        req.pc.chats[chat_id].say(req.pc, message);
                        res(null);
                }
        };
};
