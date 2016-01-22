ko = require 'knockout'
require 'knockout-mapping'
i18n = require 'i18next-ko'
md5 = require 'md5'
{TutorAppBase} = require '@tutor/app-base'
api = require './api'

ko.components.register 'page-not-found', template: "<h2>Page not found</h2>"

class ViewModel
  constructor: ->
    super
      mainElement: '#main'
      translations:
        en: '../i18n/en'

    @isActiveObservable = (path) => ko.computed => @isActive(path)

    @user = ko.observable {}
    @isLoggedIn = ko.computed => @user()? and @user().name?
    @avatarUrl = ko.computed =>
      if @isLoggedIn() then "http://www.gravatar.com/avatar/#{md5(@user().name())}?d=wavatar&f=y"

    $ =>
      api.get.me()
      .then (me) =>
        @user ko.mapping.fromJS me
        @router.goto location.hash.substr(1) #go to the page the user wants to go to
      .catch (e) =>
        @router.goto 'login'

  logout: ->
    api.post.logout()
    .then =>
      @user {}
      @router.goto 'login'

  registerPopup: ->
    $('.button').popup(position: 'bottom right', hoverable: true)

module.exports = new ViewModel()
