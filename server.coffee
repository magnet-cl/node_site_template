### This file defines the express server.

To server the content this server:
  * Uses jade for templates.
  * Uses Stylus for css
  * connect-assets to compile coffescript and manage js and dependencies

###

#SET NODE ENVIRONMENT
#process.env.NODE_ENV = 'production' # or 'production' or 'test'

# Module dependencies.
express = require("express")
routes = require("./routes")
assets = require("connect-assets")
path = require("path")
http = require('http')
gzippo = require("gzippo")
stylus = require('stylus')

# Server creation
app = module.exports = express.createServer()

# set up some configuration variables:
publicDir = __dirname + "/public"
srcDir = __dirname + "/assets"

# Stylus compile
compile = (str, path) ->
  return stylus(str)
    .import(__dirname + '/css/mixins/blueprint')
    .import(__dirname + '/css/mixins/css3')
    .set('filename', path)
    .set('warn', true)
    .set('compress', true)

# Configuration
app.configure ->
  app.set 'port', process.env.PORT || 5000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser('your secret here')
  app.use express.session()
  app.use app.router
  app.use stylus.middleware(
    src: __dirname
    dest: __dirname + '/public'
    compile: compile
  )
  app.use gzippo.staticGzip(publicDir)
  app.use assets(
    src: srcDir
    buildDir: 'public'
  )

app.configure "development", ->
  app.use express.errorHandler()

# Routes
for i, route of routes
  url = "/"
  url = "/#{i}" if i isnt 'index'
  app.get url, route

# listen to the 5000 port
http.createServer(app).listen app.get('port'), () ->
  console.log "Express server listening on port #{app.get('port')}"
