mongoose = require 'mongoose'

Pdf = new mongoose.Schema(
  title: String
  url: String
  stored: Boolean
  filename: String
  created: { type: Date, default: Date.now }
  userid: Number
  size: Number
)

mongoose.model "Pdf", Pdf

