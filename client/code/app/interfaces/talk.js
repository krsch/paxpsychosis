// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
var ko = require('knockout'),
        kb = require('knockback'),
        ss = require('socketstream');
var chats = {};
function ChatViewModel(obj,chat_id){
        this.talker = obj;
        this.chat_id = chat_id;
        this.npc = kb.viewModel(obj);
        this.messages = ko.observableArray();
        this.newmessage = ko.observable('');
}
ChatViewModel.prototype.send = function send() {
        var self = this;
        ss.rpc('pc.talk.say', this.chat_id, this.newmessage(), function(err){
                if (err) { console.error(err); }
                self.newmessage('');
        });
};
function Message(m) {
        this.text = m.message;
        this.isyou = m.talker === pc.get('_id');
}

function showChatWindow(chat_id, npc) {
        if (!chats[chat_id]) {
                var c = chats[chat_id] = { $el: $(ss.tmpl.chat.r()).appendTo(document.body) };
                c.el = c.$el[0];
                ko.applyBindings(c.vm = new ChatViewModel(npc, chat_id), c.el);
        }
        chats[chat_id].$el.dialog();
}
module.exports = function(data) {
        var actions = this.get('actions') || [],
                self = this;
        actions.push({
                id: 'talk',
                name: 'talk',
                self: this,
                click: function() {
                        var self = this;
                        console.log('talking with ', this.get('_id'), this);
                        ss.rpc('pc.talk.start chat', this.get('_id'), function(err, chat_id) {
                                if (err) { return console.error(err); }
                                showChatWindow(chat_id, self);
                        });
                }
        });
        this.set('actions', actions);
};

ss.event.on('chat:message', function(m){
        var c = chats[m.chat_id];
        console.log("New message on chat ", m.chat_id, ": ", m.message);
        console.log("From ", m.talker);
        if (c) {
                c.vm.messages.push(new Message(m));
        }
});

ss.event.on('chat:new', function(chat){
        if (chat.talker in window.people) {
                var confirm = require('../ui/confirmation');
                var el = confirm('Accept chat from ' + chat.name + '?', {yes: 'Yes', no: 'No'}, function(err, button) {
                        if (button === 'yes') {
                                showChatWindow(chat.id, people[chat.talker]);
                                ss.rpc('pc.talk.accept', chat);
                        } else {
                                ss.rpc('pc.talk.reject', chat);
                        }
                        el.remove();
                });
        } else {
                ss.rpc('pc.talk.reject', chat);
                console.error("Can't talk with someone I can't see", chat.name);
        }
});
