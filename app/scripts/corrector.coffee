app = require './app'
ko = require 'knockout'

correctionComponent = require('./pages/correction/correction')()
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
    path: /correction\/by-solution\/?(.*)/
    as: ['solutionId'] #name the parameters
    component: correctionComponent
  }
  {
    path: /correction\/?(.*)/
    as: ['exerciseId'] #name the parameters
    component: correctionComponent
  }
]

$(window).bind "popstate", ->
  app.router.goto location.hash.substr(1)

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings app
