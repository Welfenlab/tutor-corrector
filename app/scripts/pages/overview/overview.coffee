ko = require 'knockout'
api = require '../../api'
_ = require 'lodash'

class ExerciseCard
  constructor: (data) ->
    _.merge this, ko.mapping.fromJS(data)

    @dueDate = ko.computed => new Date(@exercise.dueDate())
    @formattedDueDate = ko.computed => @dueDate().toLocaleDateString()
    @isDue = ko.computed => @dueDate().getTime() < new Date().getTime()
    @isCorrected = ko.computed => @corrected() > @solutions()
    @contingent =
      should: '~' + Math.ceil data.should #TODO remove tilde once this value is exact (see issue #1)
      is: data.is
    @contingent.ratio = @contingent.is / Math.ceil data.should

  correct: -> window.location.hash = "#correction/#{@exercise.id()}"

class ViewModel
  constructor: ->
    @exercises = ko.observableArray()

    api.get.overview()
    .then (data) =>
      @exercises data.map (exercise) ->
        exercise.is = exercise.is
        exercise.should = exercise.should
        new ExerciseCard(exercise)
    .catch (e) -> console.log e

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
