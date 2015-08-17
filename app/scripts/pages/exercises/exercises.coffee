ko = require 'knockout'
api = require '../../api'
ExerciseList = require('@tutor/exercise-list')(ko)

class ExerciseViewModel extends ExerciseList.ExerciseViewModel
  constructor: (data) ->
    super(data)

  show: -> window.location.hash = '#exercise/' + @id

class ViewModel extends ExerciseList.OverviewPageViewModel
  getExercises: api.get.exercises

  createExerciseViewModel: (e) -> new ExerciseViewModel(e)

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
