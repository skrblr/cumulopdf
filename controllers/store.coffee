mongoose = require 'mongoose'
http = require 'http'
fs = require 'fs'

@root = ""

exports.initroot = (r) ->
  @root = r;
  try 
    stats = fs.lstatSync(@root)
  catch error
    fs.mkdir @root, (e) ->
      if e
        console.log e

exports.test = (req, res) ->
  res.send 'cumulopdf\n'

exports.login = (req, res) ->
  res.send "you attempted to log in\n"
 
exports.retrieve = (req, res) ->
  Resource = mongoose.model('Pdf')

  if req.params.recent?
    res.send 'not yet implemented'
  else
    Resource.find {}, (err, coll) ->
      res.send(coll)

filename = (url) ->
  f = url.split('/').pop()
  console.log f
  try 
    stats = fs.lstatSync @root + '/' + f
    if (stats.isFile())
      rightNow = new Date(); 
      res = rightNow.toISOString().slice(0,10).replace(/-/g,"");
      f = f.slice(0,-4) + '_' + res + '.pdf'
  catch error
    if not error.code is 'ENOENT'
      console.log error
  console.log f
  f

filesizeinkb = (filename) ->
  stats = fs.statSync(filename)
  size = stats["size"] / 1024
  size

download = (url, dest, cb) ->
  console.log 'dest', dest
  file = fs.createWriteStream(dest)
  request = http.get(url, (response) ->
    response.pipe file
    file.on('finish', ->
      file.close
      cb
    )
  )
                   
exports.add = (req, res) ->
  Resource = mongoose.model 'Pdf' 
  json = req.body
  console.log json
  url = json["url"]
  downloaded = 0
  file = ""
  size = 0

  if json["download"] is 1
    download url, @root + filename url, () ->
      downloaded = 1
      file = filename url
      size = filesizeinkb file
      
  fields = {
    title: "",
    url: url,
    stored: downloaded,
    filename: file,
    userid: 0,
    size: size
  }
  console.log fields

  r = new Resource(fields)
  r.save (err, resource) ->
    res.send 500, {error: err} if err?
    res.send resource
                                             
