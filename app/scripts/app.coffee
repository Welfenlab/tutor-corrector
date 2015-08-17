ko = require 'knockout'
require 'knockout-mapping'
api = require './api'
#not_found = './pages/not_found'
fs = require 'fs'
login = require '@tutor/login-form'
i18n = require('i18next-ko')

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

viewModel =
  user: ko.observable({
    loggedIn: yes
    name: 'Jon Doe'
    avatar: 'http://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?f=y&d=monsterid'
  })

  availableLanguages: ['en']
  language: ko.observable 'en'

  selected: ko.observable()
  parameters: ko.observable {}
  path: ko.observable()

  pages: [
    {
      path: 'login'
      component: require('./pages/login/login')()
    },
    {
      path: 'overview'
      component: require('./pages/exercises/exercises')()
    },
    {
      path: /exercise\/?(.*)/
      as: ['id'] #name the parameters
      component: require('./pages/editor/editor')()
    }
  ]

rename = (array, names) ->
  obj = {}
  for item, i in array
    obj[names[i]] = item
  return obj

i18n.init {
  en:
    translation: require '../i18n/en'
  }, 'en', ko
viewModel.language.subscribe (v) -> i18n.setLanguage v

viewModel.path.subscribe (v) ->
  if v is ''
    v = 'login'

  found = no
  result = null
  for page in viewModel.pages
    if page.path is v or (result = v.match page.path) isnt null
      if result?
        viewModel.parameters rename result.slice(1), page.as
      else
        viewModel.parameters {}
      viewModel.selected page.component
      found = yes
      break

  if not found
    viewModel.selected 'page-not-found'

$(window).bind "popstate", ->
  path = location.hash.substr(1);
  viewModel.path path

$(window).trigger "popstate" #trigger load of start page

$(document).ready ->
  $('.ui.dropdown').dropdown()
  $('.ui.accordion').accordion()
  ko.applyBindings viewModel
