// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

var mongoose = require('mongoose'),
        Schema = mongoose.Schema,
        ObjectId = Schema.ObjectId,
        Invite = new Schema({
                by: {type: ObjectId, ref: 'User'},
                user: {type: ObjectId, ref: 'User'}
        });
module.exports = mongoose.model('Invite', Invite);
