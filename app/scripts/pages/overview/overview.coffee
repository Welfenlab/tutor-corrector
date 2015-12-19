ko = require 'knockout'
api = require '../../api'
app = require '../../app'
_ = require 'lodash'
moment = require 'moment'

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

  correct: -> app.router.goto "correction/#{@exercise.id()}"

class UnfinishedCorrection
  constructor: (data) ->
    @correction = data
    @exercise = ko.observable({})
    api.get.exercise(data.exercise).then (data) => @exercise(data)
    @lockDateText = moment(data.lockTimeStamp).from(Date.now())
    @hash = data.id.substr(0, 8)

  show: ->
    app.router.goto "correction/by-solution/#{@correction.id}"

class ViewModel
  constructor: ->
    @exercises = ko.observableArray()
    @lockedCorrections = ko.observableArray()

    api.get.overview()
    .then (data) =>
      @exercises data.map (exercise) ->
        exercise.is = exercise.is
        exercise.should = exercise.should
        new ExerciseCard(exercise)
    .catch (e) -> console.log e

    api.get.unfinishedCorrections()
    .then (data) =>
      data = _.chain(data)
        .sortByOrder('lockTimeStamp', 'desc')
        .map (correction) -> new UnfinishedCorrection(correction)
        .value()
      @lockedCorrections data
    .catch (e) -> console.log e


fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
