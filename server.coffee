express = require('express')
fs = require('fs')
app = express()
bodyParser = require('body-parser')
sass = require("node-sass")
coffeem = require('coffee-middleware')
path = require('path')

allowCrossDomain = (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With')
  if 'OPTIONS' is req.method then res.send(200) else next()

renderAll = ->
  stylesheet = "public/stylesheets/style.css"
  if fs.existsSync(stylesheet)
    fs.unlinkSync stylesheet
    css = sass.renderSync
      file: 'app/stylesheets/style.scss'
    fs.writeFileSync stylesheet, css

app.set 'views', 'app/views'
app.set 'view engine', 'jade'

app.use allowCrossDomain
app.use bodyParser.urlencoded()

app.use express.static('public')
app.use sass.middleware
  src: 'app'
  dest: 'public'
  debug: false
app.use coffeem
  src: 'app/js'
  compress: true
  bare: true
  force: true

app.get '/', (req, res) ->
  renderAll()
  res.render 'examples/boilerplate', (err, html) ->
    res.render 'index',
      html: html
app.get '/:view',  (req, res) ->
  renderAll()
  res.render 'examples/'+req.params.view, (err, html) ->
    res.render 'index',
      html: html
app.get '/favicon.ico', (req, res) -> res.send('Not Found.', 404)

server = require('http').Server(app).listen(8080)