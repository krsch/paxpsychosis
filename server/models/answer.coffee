# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Answer = new Schema {
  text: String
  dialog: {type: ObjectId, ref: 'Dialog'}
  from: {type: ObjectId, ref: 'Question'}
  to: {type: ObjectId, ref: 'Question'}
}
Answer.index({dialog: 1})

module.exports = mongoose.model('Answer', Answer)

