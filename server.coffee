### This file defines the express server.

To server the content this server:
  * Uses jade for templates.
  * Uses Stylus for css
  * Uses connect-assets to compile coffescript and manage js and dependencies
  * Uses gzippo for compress in production environment

###


# MODULES ----------------------------------------------------------------------
# Dependencies
assets = require("connect-assets")
bytes = require("bytes")
express = require("express")
gzippo = require("gzippo")
http = require('http')
path = require("path")
program = require('commander')
stylus = require('stylus')

# Logger format "solarized"
express.logger.format "solarized", (tokens, req, res) ->
  statusCode = res.statusCode
  method = req.method
  url = req.originalUrl
  time = "#{(new Date - req._startTime)}ms"

  len = parseInt(res.getHeader("Content-Length"), 10)
  len = if isNaN(len) then "?" else "#{bytes len}"

  color = 34 #blue
  if statusCode >= 500
    color = 31 #red
  else if statusCode >= 400
    color = 33 #
  else color = 32 if statusCode >= 300

  status = "\u001b[#{color}m#{statusCode}"

  "\u001b[0m#{method} #{url} #{status} \u001b[0m#{time} - #{len} \u001b[0m"

# Stylus compile
compile = (str, path) ->
  return stylus(str)
    .import(__dirname + '/css/mixins/blueprint')
    .import(__dirname + '/css/mixins/css3')
    .set('filename', path)
    .set('warn', true)
    .set('compress', true)


# VARIABLES --------------------------------------------------------------------
routes = require("./routes")
publicDir = __dirname + "/public"
srcDir = __dirname + "/assets"


# PROGRAM ----------------------------------------------------------------------
# Configuration
program
  .version('0.0.2')
  .usage('[options]')
  .option('--env [string]', 'select environment')
  .option('--logger [string]', 'select logger format')
  .option('-p, --port [number]', 'select port')

# Parse arguments
program.parse process.argv

# Check and set environment
if program.env
  if program.env in ['production', 'test', 'development']
    process.env.NODE_ENV = program.env

# Check and set logger format
logger_format = if program.logger then program.logger else 'dev'

# Check and set port
process.env.PORT = 5000
if program.port
  port = program.port*1
  if typeof port is 'number' and port > 79
    process.env.PORT = program.port

# Expres Application -----------------------------------------------------------
# Creation
app = express()

# Configuration
app.configure ->
  app.set 'port', process.env.PORT
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.cookieParser('magnet_node_site_template')
  app.use express.logger(logger_format)
  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.methodOverride()
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

# Development Configuration
app.configure "development", ->
  app.use express.errorHandler()

# Routes

for i, route of routes
  url = "/"
  url = "/#{i}" if i isnt 'index'
  app.get url, route

# HTTP SERVER ------------------------------------------------------------------
# Creation
http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
