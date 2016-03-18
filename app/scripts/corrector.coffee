app = require './app'
ko = require 'knockout'

correctionComponent = require('./pages/correction/correction')()

$ ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()

  app.route '/', -> app.goto '/overview'
  app.route '/login', component: require('./pages/login/login')(), loginRequired: no
  app.route '/overview', component: require('./pages/overview/overview')()
  app.route '/students', component: require('./pages/students/students')()
  app.route '/correction/by-solution/:solutionId', component: correctionComponent
  app.route '/correction/:exerciseId', component: correctionComponent

  ko.applyBindings app
