module.exports = require('requireindex')(__dirname)

module.exports.index = (req, res) ->
  res.render 'other', title: 'Template | Other page'
