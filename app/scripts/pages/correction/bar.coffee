ko = require 'knockout'
_ = require 'lodash'

class CorrectionBarViewModel
  constructor: (@exercise, @solution, @allPoints) ->
    @selectedTaskIndex = ko.observable 0

    @tasks = ko.computed =>
      if !@exercise()
        return []
      return @exercise().tasks

    @tests = ko.computed =>
      if !@solution() or !@solution().tasks[@selectedTaskIndex()]
        return []
      return @solution().tasks[@selectedTaskIndex()].tests || []

    @passedTests = ko.computed => _.filter @tests(), 'passes'

    @task = ko.computed =>
      if !@exercise()
        return {}
      @exercise().tasks[@selectedTaskIndex()]

    @taskPoints = ko.pureComputed
      read: =>
        if !@allPoints()
          return {}
        @allPoints()[@selectedTaskIndex()]
      write: (value) =>
        @allPoints()[@selectedTaskIndex()] = value
        @allPoints @allPoints()

    @canGoNext = ko.computed => @selectedTaskIndex() < @tasks().length - 1
    @canGoPrev = ko.computed => @selectedTaskIndex() > 0

  next: ->
    @selectedTaskIndex @selectedTaskIndex() + 1

  prev: ->
    @selectedTaskIndex @selectedTaskIndex() - 1

  onShow: ->
    $('#showtests').popup(inline: true)

module.exports = CorrectionBarViewModel
