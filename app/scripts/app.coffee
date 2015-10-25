ko = require 'knockout'
require 'knockout-mapping'
#not_found = './pages/not_found'
i18n = require 'i18next-ko'
md5 = require 'md5'
Router = require './router'
api = require './api'

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    @router = new Router()
    @isActive = (path) => ko.computed => @router.path().indexOf(path) == 0

    @user = ko.observable {}
    api.get.me()
    .then (me) =>
      @user ko.mapping.fromJS me
      @router.goto location.hash.substr(1) #go to the page the user wants to go to
    .catch (e) =>
      @router.goto 'login'

    @isLoggedIn = ko.computed => @user()? and @user().name?
    @avatarUrl = ko.computed =>
      if @isLoggedIn() then "http://www.gravatar.com/avatar/#{md5(@user().name())}?d=wavatar&f=y"

    @availableLanguages = ['en']
    @language = ko.observable 'en'
    @language.subscribe (v) -> i18n.setLanguage v

  logout: ->
    api.post.logout()
    .then =>
      @user {}
      @router.goto 'login'

  registerPopup: ->
    $('.button').popup(position: 'bottom right', hoverable: true)

i18n.init {
  en:
    translation: require '../i18n/en'
  }, 'en', ko

module.exports = new ViewModel()
