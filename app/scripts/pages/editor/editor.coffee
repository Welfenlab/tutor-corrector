ko = require 'knockout'
api = require '../../api'
ExerciseList = require '@tutor/exercise-editor'

class ViewModel extends ExerciseList(ko)
  show: (id) -> window.location.hash = '#exercise/' + id
  getExercises: api.get.exercises


fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
