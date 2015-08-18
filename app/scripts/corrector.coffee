app = require './app'
ko = require 'knockout'

app.router.pages [
  {
    path: 'login'
    component: require('./pages/login/login')()
  }
  {
    path: 'overview'
    component: require('./pages/overview/overview')()
  }
  {
    path: 'students'
    component: require('./pages/students/students')()
  }
  {
    path: /exercise\/?(.*)/
    as: ['id'] #name the parameters
    component: require('./pages/editor/editor')()
  }
]

app.router.goto 'login'

$(window).bind "popstate", ->
  app.router.goto location.hash.substr(1)

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
