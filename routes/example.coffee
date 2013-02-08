module.exports = require('requireindex')(__dirname)

module.exports.index = (req, res) ->
  res.render 'example', title: 'Template | Example page'
