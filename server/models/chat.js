"use strict";
var max_id = 0;
module.exports = function Chat() {
        this.id = max_id++;
        this.talkers = [];
};

Chat.prototype.say = function say(pc, message) {
        var self = this;
        this.pcs.forEach(function(each) {
                each.publish("chat:message", {chat_id: self.id, talker: pc._id, message: message});
        });
};

Chat.prototype.add = function add(pc) {
        this.talkers.push(pc);
        if (!pc.chats) { pc.chats = {}; }
        pc.chats[this.id] = this;
        return this;
};
