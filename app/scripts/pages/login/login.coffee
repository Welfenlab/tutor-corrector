ko = require 'knockout'

class ViewModel
  constructor: ->
    @username = ko.observable ''
    @password = ko.observable ''

    @mayLogin = ko.computed =>  @username isnt '' and @password isnt ''
    @isLoggingIn = ko.observable no

  login: ->


fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
