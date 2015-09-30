ko = require 'knockout'
api = require '../../api'

class ViewModel
  constructor: ->
    @exercises = ko.observableArray()

    api.get.overview()
    .then (data) =>
      number = 1
      @exercises data.map (exercise) ->
        vm = ko.mapping.fromJS(exercise)
        vm.number = number++
        vm.dueDate = new Date()
        vm.formattedDueDate = vm.dueDate.toLocaleDateString()
        vm.isDue = ko.computed -> vm.dueDate.getTime() < new Date().getTime()
        vm.isCorrected = vm.corrected() > vm.solutions()
        return vm
    .catch (e) -> console.log e

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
