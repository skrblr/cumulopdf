express = require 'express'
sys = require 'sys'
mongoose = require 'mongoose'
pdfs = require './models/pdf.coffee'
store = require './controllers/store.coffee'
app = express()

app.configure -> 
  app.use express.static __dirname + '/public'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.set "port", process.env.PORT or 3333
  app.set 'storage-uri',
    process.env.MONGOHQ_URL or
    process.env.MONGOLAB_URI or
    'mongodb://localhost/pdfs'

mongoose.connect app.get('storage-uri'), { db: { safe: true }}, (err) ->
  console.log "Mongoose - connection error: " + err if err?
  console.log "Mongoose - connection okay"

store.initroot(__dirname + '/storage/')

app.get '/test', store.test
app.post '/login', store.login
app.get '/', store.retrieve
app.get '/pdfs', store.retrieve 
app.get '/pdfs/recent/:recent', store.retrieve
app.post '/store', store.add 

app.listen app.get 'port'
