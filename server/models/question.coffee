# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Question = new Schema {
  text: String
  dialog: {type: ObjectId, ref: 'Dialog'}
}
Question.index({dialog: 1})

module.exports = mongoose.model('Question', Question)
