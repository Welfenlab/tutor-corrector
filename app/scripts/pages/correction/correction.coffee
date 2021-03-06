ko = require 'knockout'
require 'pdfjs-dist/build/pdf.combined' #defines PDFJS globaly
#PDFJS.workerSrc = false
scribblejs = require 'scribble.js'
Q = require 'q'
_ = require 'lodash'
app = require '../../app'
api = require '../../api'
CorrectionBarViewModel = require './bar'

class ViewModel
  constructor: (@params) ->
    if not $? then console.error 'No jQuery defined'
    if not $.fn.scribble then scribblejs($)

    @pages = ko.observableArray()
    @pageCount = ko.computed => @pages().length
    @color = ko.observable()
    @tool = ko.observable('marker')

    @isLoading = ko.observable(true)
    @exercise = ko.observable()
    @solution = ko.observable()
    @isCorrecting = ko.computed => !@isLoading() && @exercise() && @solution()
    @points = ko.observable()
    @points.subscribe => @isSaved false
    @correctionBar = new CorrectionBarViewModel @exercise, @solution, @points

    @loadSolution = => #load the solution and pdf for the current exercise
      if !@exercise()
        @pages []
        return Q.reject()

      getSolution = api.get.nextSolution @exercise().id
        .then (solution) =>
          @solution solution

      getSolution.then =>
        if @solution()
          @loadPdf().then => @initPages()
        else
          $('#noMoreSolutions').modal(closable: false).modal('show')

    @loadExercise = => #load the exercise and pdf for the current solution
      if !@solution()
        @pages []
        return Q.reject()
      getExercise = api.get.exercise @solution().exercise
        .then (exercise) => @exercise exercise

      getExercise.then(=> @loadPdf()).then(=> @initPages())

    @initPages = =>
      results = @solution().results
      @points new Array(@solution().tasks.length)
      if results
        @points results.points
        for page,i in @pages()
          page.scribble.loadShapes(results.pages[i].shapes || [], true)
      @isSaved true

    @isSaving = ko.observable false
    @isSaved = ko.observable true

    @canUndo = ko.observable no
    @canRedo = ko.observable no
    @undoStack = new scribblejs.Undo()
    @undoStack.on 'undoAvailable', => @canUndo yes
    @undoStack.on 'undoUnavailable', => @canUndo no
    @undoStack.on 'redoAvailable', => @canRedo yes
    @undoStack.on 'redoUnavailable', => @canRedo no

    @autosave = _.throttle (=> @save() if not @isSaved()), 10000

    @canFinalize = ko.computed => @isSaved() and _.every @points(), (p) -> typeof parseInt(p) is 'number'
    @isFinalizing = ko.observable false

  onShow: =>
    $(document).on 'keydown.correction', (event) =>
      if event.ctrlKey
        switch event.keyCode
          when 90
            if event.shiftKey #Ctrl+Shift+Z
              @redo()
            else #Ctrl+Z
              @undo()
          when 89 then @redo() #Ctrl+Y
          when 83 then @save() #Ctrl+S
          else return
      else if event.altKey
        switch event.keyCode
          when 49 then @tool 'marker'      #Alt+1
          when 50 then @tool 'highlighter' #Alt+2
          when 51 then @tool 'text'        #Alt+3
          when 52 then @tool 'eraser'      #Alt+4
          when 82 then @color '#f00'       #Alt+R
          when 89 then @color '#ff0'       #Alt+Y
          when 71 then @color '#0f0'       #Alt+G
          else return
      else
        return #only preventDefault() if this was a shortcut
      event.preventDefault()

    $(document).on 'scroll.correction', (event) ->
      if $(window).scrollTop() > 0
        $('.correction .toolbar').addClass 'floating'
      else
        $('.correction .toolbar').removeClass 'floating'

    # $('#correctionCanvas').scribble()
    # @scribble = $('#correctionCanvas').scribble()

    $(window).on 'resize.correction', => @resize()

    @color.subscribe (v) =>
      for page in @pages()
        page.scribble.set 'color', v
    @color '#f00'

    @tool.subscribe (v) =>
      for page in @pages()
        page.scribble.set 'tool', v
        switch v
          when 'marker'
            page.scribble.set 'size', 5
          when 'highlighter'
            page.scribble.set 'size', 20
          when 'text'
            page.scribble.set 'size', 20
          else
            page.scribble.set 'size', 5
    @tool 'marker'

    if @params.exerciseId
      api.get.exercise @params.exerciseId
      .then (exercise) =>
        @exercise exercise
        @loadSolution()
        .then => @isLoading(false)
      .catch (e) =>
        @isLoading(false)
        console.error(e)
        alert 'Could not load this solution.'
    else if @params.solutionId
      api.get.solution @params.solutionId
      .then (solution) =>
        @solution solution
        @loadExercise()
        .then => @isLoading(false)
      .catch (e) =>
        @isLoading(false)
        console.error(e)
        alert 'Could not load this solution.'

  loadPdf: ->
    PDFJS.getDocument(api.urlOf.pdf(@solution().id))
    .then (pdf) =>
      Q.all [1..pdf.numPages].map (pageNo) ->
          pdf.getPage(pageNo).then (page) ->
            #create an off-screen canvas for rendering the pdf
            canvas = document.createElement('canvas')
            ctx = canvas.getContext('2d')

            #get pdf size and set canvas size accordingly
            viewport = page.getViewport(2.0) #2.0 is the zoom level
            canvas.width = viewport.width
            canvas.height = viewport.height

            #render the page and put it into an image
            page.render({canvasContext: ctx, viewport: viewport}).then ->
              deferred = Q.defer()
              pdfImage = new Image()
              pdfImage.onload = =>
                deferred.resolve
                  image: pdfImage
                  pageNo: pageNo
                  width: pdfImage.width
                  height: pdfImage.height
              pdfImage.src = canvas.toDataURL()
              canvas.remove()
              return deferred.promise
    .then (pages) =>
      pages.sort (a, b) -> a.pageNo - b.pageNo
      @pages pages
      @resize()

  registerCanvas: (page, element) ->
    canvas = $(element)
    canvas.scribble(undo: @undoStack)
    page.canvas = canvas
    page.scribble = canvas.scribble() #second scribble() call returns the scribble instance
    page.scribble.background = page.image
    page.scribble.set 'color', @color()
    page.scribble.set 'tool', @tool()
    canvas.on 'afterPaint', =>
      @isSaved false
      @autosave()

  unregisterCanvas: (element) ->
    canvas = $(element)

  onHide: ->
    $('#correctionCanvas').off '.correction'
    $(window).off '.correction'
    $(document).off '.correction'

  undo: ->
    @undoStack.undo()
    @isSaved false
  redo: ->
    @undoStack.redo()
    @isSaved false

  save: ->
    @isSaving true

    result =
      points: @points()
      pages: []
    for page in @pages()
      result.pages.push
        page: page.pageNo
        shapes: page.scribble.getShapes()

    api.put.correction @solution().id, result
    .then =>
      @isSaving false
      @isSaved true
    .catch =>
      @isSaving false

  finalize: ->
    @isFinalizing true
    api.put.finalizeCorrection @solution().id
    .then =>
      @isFinalizing false
      @exercise null
    .catch =>
      @isFinalizing false

  resize: ->
    for page in @pages()
      actualWidth = page.canvas.width()
      page.canvas.parent().height actualWidth / page.width * page.height
      page.canvas.attr
        height: actualWidth / page.width * page.height
        width: actualWidth
      page.scribble.setScale actualWidth / page.width

  gotoOverview: ->
    $('.ui.modal').modal('hide')
    app.goto 'overview'

  takeBreak: ->
    window.open _.sample [
      "https://www.reddit.com/r/ProgrammerHumor"
      "http://thecodinglove.com/random"
      "http://c.xkcd.com/random/comic/"
    ]


fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)
