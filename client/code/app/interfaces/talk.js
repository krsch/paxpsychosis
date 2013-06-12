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
        this.isyou = m.from === pc.get('_id');
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
                        ss.rpc('pc.talk.start chat', this.get('_id'), function(err, chat_id) {
                                if (err) { return console.error(err); }
                                if (!chats[chat_id]) {
                                        var c = chats[chat_id] = { $el: $(ss.tmpl.chat.r()).appendTo(document.body) };
                                        c.el = c.$el[0];
                                        ko.applyBindings(c.vm = new ChatViewModel(self, chat_id), c.el);
                                }
                                chats[chat_id].$el.dialog();
                        });
                }
        });
        this.set('actions', actions);
};

ss.event.on('chat:message', function(m){
        var c = chats[m.chat];
        if (c) {
                c.vm.messages.push(new Message(m));
        }
});
