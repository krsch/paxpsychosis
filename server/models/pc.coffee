mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Pc = new Schema {
  name: String
  factionId: ObjectId
  userId: {type: ObjectId, unique: true}
  loc: [{type: Number, index: {"2d": true}}]
}
module.exports = mongoose.model('PC', Pc)
