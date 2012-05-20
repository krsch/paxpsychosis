mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Pc = new Schema {
  name: String
  factionId: ObjectId
  userId: ObjectId
  loc: [Number]
}
module.exports = mongoose.model('PC', Pc)
