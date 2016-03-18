ko = require 'knockout'
require 'knockout-mapping'
md5 = require 'md5'
{TutorAppBase} = require '@tutor/app-base'
api = require './api'

class ViewModel extends TutorAppBase($, ko)
  constructor: ->
    super
      mainElement: '#main'
      translations:
        en: require '../i18n/en'

    @isActiveObservable = (path) => ko.computed => @isActive(path)

    @user = ko.observable {}
    @isLoggedIn = ko.computed => @user()? and @user().name?
    @avatarUrl = ko.computed =>
      if @isLoggedIn() then "http://www.gravatar.com/avatar/#{md5(@user().name())}?d=wavatar&f=y"

    $ =>
      api.get.me()
      .then (me) =>
        @user ko.mapping.fromJS me
        @goto(localStorage.getItem('post-login-redirect') || @path(), true)
        localStorage.removeItem('post-login-redirect')
      .catch (e) =>
        localStorage.setItem('post-login-redirect', @path())
        @goto 'login'

  logout: ->
    api.post.logout()
    .then =>
      @user {}
      @goto 'login'

  registerPopup: ->
    $('.button').popup(position: 'bottom right', hoverable: true)

module.exports = new ViewModel()
