"use strict";
var mongoose = require('mongoose'),
        $ = require('interlude'), 
        deepEqual = require('deep-equal'),
        _ = require('lodash'),
        Geo = require('geojs'),
        ss = require('socketstream').api,
        Schema = mongoose.Schema,
        ObjectId = Schema.ObjectId,
        movement = require('./movement'),
        pc_schema = new Schema({
                name: String,
                factionId: ObjectId,
                userId: {
                        type: ObjectId,
                        index: true
                },
                speed: {
                        fly: {
                                type: Number,
                                "default": 5e-6
                        }
                },
                loc: {
                        type: [Number],
                        index: "2d"
                },
                skills: Schema.Types.Mixed
        });
var model = mongoose.model('PC', pc_schema);
function look_around (pc) {}
function skillLevel2Value(level) {
        if (level < 0) {
                return 'лох';
        } else if (level < 5) {
                return 'нуб';
        } else if (level < 10) {
                return 'норм';
        } else if (level < 15) {
                return 'крут';
        } else {
                return 'супер';
        }
}



function log_error(err) {
        if (err) { return console.error(err); }
}

function Pc(doc) {
        var _this = this;
        this.doc = doc;
        if (this.doc._id in cache.pc) {
                throw new Error("PC document not loaded into cache but trying to be created");
        }
        this._id = this.doc._id;
        this.around = [];
        this.loc = new Geo.Pos({
                lon: this.doc.loc[0],
                lat: this.doc.loc[1]
        });
        this.movement = movement(this.loc, this.doc.speed);
        this.movement.on('change:movement', function(movement) {
                return _this.publish('pcMove', movement);
        });
        this.movement.on('change:direction', function(movement) {
                return _this.notify_movement(movement);
        });
        this.movement.on('change:position', function(loc) {
                _this.loc = new Geo.Pos(loc);
                _this.doc.loc = [loc.lon, loc.lat];
                model.update({
                        _id: _this._id
                }, {
                        $set: {
                                loc: _this.doc.loc
                        }
                }, log_error);
                return look_around(_this);
        });
}

Pc.adopt = function(doc) {
        if (doc._id in cache.pc) {
                throw new Error("PC document not loaded into cache but trying to be created");
                // return cache.pc[doc._id];
        } else {
                return (cache.pc[doc._id] = new Pc(doc));
        }
};

Pc.create = function(params, cb) {
        return model.create(params, function(err, doc) {
                if (err) {
                        return cb(err);
                } else {
                        return cb(null, Pc.adopt(doc));
                }
        });
};

function by_id(_id, cb) {
        if (_id in cache.pc) {
                return cb(null, cache.pc[_id]);
        } else {
                return model.findById(_id, function(err, doc) {
                        if (err) { return cb(arguments); }
                        if (!doc) { return cb('Not found'); }
                        if (_id in cache.pc) {
                                return cache.pc[_id];
                        } else {
                                return cb(null, Pc.adopt(doc));
                        }
                });
        }
}
Pc.prototype.publish = function(topic, message) {
        return ss.publish.channel('pc:' + this.doc._id, topic, message);
};

Pc.prototype.updatePos = function() {
        return this.movement.force();
};

Pc.prototype.move = function() {
        var _ref;
        return (_ref = this.movement).move.apply(_ref, arguments);
};

Pc.prototype.notify_movement = function(m) {
        var _this = this;
        return this.around.forEach(function(pc) {
                return by_id(pc, function(err, pc) {
                        if (err) { throw new Error(err); }
                        return pc.see(_this, m);
                });
        });
};

Pc.prototype.notify_chat = function(chat) {
        var other = _.without(chat.talkers, this)[0];
        return this.publish('chat:new', {
                id: chat.id,
                talker: other._id,
                name: other.doc.name
        });
};

Pc.jsonify = function(doc) {
        var cat, skills;
        skills = {};
        for (cat in doc.skills) {
                skills[cat] = doc.skills[cat].map(function(skill) {
                        return {
                                name: skill.name,
                                value: skillLevel2Value(skill.level)
                        };
                });
        }
        return {
                _id: doc._id,
                name: doc.name,
                loc: {
                        lon: doc.loc[0],
                        lat: doc.loc[1]
                },
                skills: skills
        };
};

Pc.prototype.toJSON = function() {
        return Pc.jsonify(this.doc);
};

Pc.prototype.see = function(pc, m) {
        if (pc._id === this._id) {
                console.log(pc._id, this._id, this.around);
        }
        return this.publish('you see', {
                _id: pc._id,
                loc: {
                        lat: pc.doc.loc[1],
                        lon: pc.doc.loc[0]
                },
                movement: m !== undefined ? m : pc.movement.direction()
        });
};

Pc.prototype.lost = function(pc) {
        return this.publish('you lost', {
                _id: pc._id
        });
};

function by_user(userId, cb) {
        return model.findOne({
                userId: userId
        }, function(err, doc) {
                if (err) {
                        return cb.apply(null, arguments);
                }
                if (doc == null) {
                        return cb('not found');
                }
                return cb(null, doc._id in cache.pc ? cache.pc[doc._id] : Pc.adopt(doc));
        });
}


function names_by_user(userId, cb) {
        return model.find({
                userId: userId
        }, function(err, docs) {
                if (err) {
                        return cb(err);
                }
                return cb(null, docs.map(Pc.jsonify));
        });
}

Pc.prototype.sees_only = function(pc) {
        var equals, new_pcs, old_pcs, pc_ids,
        _this = this;
        pc_ids = this.around.map(function(e) {
                return {
                        _id: e
                };
        });
        equals = function(a, b) {
                return String(a._id) === String(b._id);
        };
        new_pcs = $.differenceBy(equals, pc, pc_ids);
        old_pcs = $.differenceBy(equals, pc_ids, pc);
        old_pcs.forEach(function(pc) {
                return by_id(pc._id, function(err, pc) {
                        if (err) {
                                throw err;
                        }
                        pc.lost(_this);
                        return _this.lost(pc);
                });
        });
        new_pcs.forEach(function(pc) {
                return by_id(pc._id, function(err, pc) {
                        if (err) {
                                throw err;
                        }
                        pc.see(_this);
                        return _this.see(pc);
                });
        });
        this.around = pc.map(function(e) { return e._id; });
};

module.exports = {
        model: model,
        by_id: by_id,
        by_user: by_user,
        create: Pc.create,
        adopt: Pc.adopt,
        jsonify: Pc.jsonify,
        json_by_user: names_by_user,
        find: function(query, cb) {
                return model.find(query, function(err, docs) {
                        if (err) {
                                cb(arguments);
                        }
                        return cb(null, docs.map(function(doc) {
                                if (cache.pc[doc._id]) {
                                        return cache.pc[doc._id];
                                } else {
                                        return Pc.adopt(doc);
                                }
                        }));
                });
        }
};

