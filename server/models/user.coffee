mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
User = new Schema {
  login: String
  password: String
}
module.exports = mongoose.model('User', User)

