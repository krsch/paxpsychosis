// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";

var mongoose = require('mongoose'),
        Schema = mongoose.Schema,
        ObjectId = Schema.ObjectId,
        Invite = new Schema({
                by: {type: ObjectId, ref: 'User'},
                user: {type: ObjectId, ref: 'User'},
                created_at: {type: Date, 'default': new Date(0)},
                used_at: {type: Date, 'default': new Date(0)},
                comment: {type: String, 'default': ''}
        });
module.exports = mongoose.model('Invite', Invite);
