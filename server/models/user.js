// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
var     mongoose = require('mongoose'),
        Schema = mongoose.Schema,
        ObjectId = Schema.ObjectId,
        User = new Schema({
          login: String,
          password: String,
          admin: {type: Boolean, 'default': false}
        });
var active_pc = {};
var by_sid = {};

User.methods.dologin = function login(session, sid, cb) {
        by_sid[sid] = this;
        session.userId = this._id;
        session.admin = this.admin;
        session.save(function(err) { cb(err); } );
};
User.methods.selectpc = function selectpc(pc_id, session, cb) {
        active_pc[this._id] = pc_id;
        var Pc = require('./pc');
        Pc.by_id(pc_id, function(err, pc){
                if (err) { return cb(err); }
                if (pc.doc.userId != session.userId) { return cb('Bad pc_id'); }
                if (pc.session) {
                        pc.publish('selectpc', 'Someone selected this PC. If it is not you, someone might have hacked you');
                        delete pc.session.pc_id;
                        pc.session.save();
                }
                pc.session = session;
                session.pc_id = pc_id;
                session.channel.subscribe('pc:'+pc._id);
                session.save(function(err) { cb(err); } );
        });
};
User.statics.getPc = function getPc(userId) {
        if (userId) { return active_pc[userId]; }
        else { return active_pc; }
};
User.statics.by_sid = function (sid) {
        return by_sid[sid];
};
exports = module.exports = mongoose.model('User', User);

