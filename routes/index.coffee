module.exports = require('requireindex')(__dirname)

module.exports.index = (req, res) ->
  res.render 'index', title: 'Template | Index page'
