"use strict";
var max_id = 0, Chat;
module.exports = Chat = function Chat() {
        this.id = max_id++;
        this.talkers = [];
};

Chat.prototype.say = function say(pc, message) {
        var self = this;
        this.talkers.forEach(function(each) {
                each.publish("chat:message", {chat_id: self.id, talker: pc._id, message: message});
        });
};

Chat.prototype.add = function add(pc) {
        this.talkers.push(pc);
        if (!pc.chats) { pc.chats = {}; }
        pc.chats[this.id] = this;
        return this;
};
