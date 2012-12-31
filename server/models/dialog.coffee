# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Dialog = new Schema {
  title: String
  start: {type: ObjectId, ref: 'Question'}
}
Dialog.index({dialog: 1})

module.exports = mongoose.model('Dialog', Dialog)
