ko = require 'knockout'
api = require '../../api'
_ = require 'lodash'

class ExerciseCard
  constructor: (data) ->
    _.merge this, ko.mapping.fromJS(data)
    console.log this
    @number = Math.random() * 42 | 0
    @dueDate = new Date(data.dueDate || 0)
    @formattedDueDate = @dueDate.toLocaleDateString()
    @isDue = ko.computed => @dueDate.getTime() < new Date().getTime()
    @isCorrected = ko.computed => @corrected() > @solutions()
    @contingent =
      should: 42
      is: 21
    @contingent.ratio = @contingent.is / @contingent.should

  correct: -> window.location.hash = "#exercise/#{@exercise()}"

class ViewModel
  constructor: ->
    @exercises = ko.observableArray()

    api.get.overview()
    .then (data) =>
      number = 1
      @exercises data.map (exercise) ->
        exercise.number = number++
        new ExerciseCard(exercise)
    .catch (e) -> console.log e

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
