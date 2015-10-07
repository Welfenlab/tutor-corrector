ko = require 'knockout'
require 'pdfjs-dist/build/pdf.combined' #defines PDFJS globaly
#PDFJS.workerSrc = false
scribblejs = require 'scribble.js'
Q = require 'q'
_ = require 'lodash'
api = require '../../api'

class ViewModel
  constructor: (params) ->
    if not $? then console.error 'No jQuery defined'
    if not $.fn.scribble then scribblejs($)

    @pendingCorrections = ko.observableArray()
    api.get.pendingCorrections params.id
    .then (pending) => @pendingCorrections pending

    @correction = ko.observable({id: 42}) #TODO get correction
    @pages = ko.observableArray()
    @pageCount = ko.computed => @pages().length
    @color = ko.observable()
    @tool = ko.observable('marker')
    @exercise = ko.observable params.id
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

  onShow: =>
    $(document).on 'keydown.correction', (event) =>
      event.preventDefault()
      if event.keyCode == 90 and event.ctrlKey #Ctrl+Z
        if event.shiftKey #Ctrl+Shift+Z
          @redo()
        else
          @undo()
      else if event.keyCode == 89 and event.ctrlKey #Ctrl+Y
        @redo()
      else if event.keyCode == 83 and event.ctrlKey #Ctrl+S
        @save()

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

    PDFJS.getDocument(api.urlOf.pdf(@exercise()))
    .then (pdf) =>
      Q.all(
        for pageNo in [1..pdf.numPages]
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
      )
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

  undo: -> @undoStack.undo()
  redo: -> @undoStack.redo()

  save: ->
    @isSaving true

    solution =
      points: []
      pages: []
    for page in @pages()
      solution.pages.push
        page: page.pageNo
        shapes: page.scribble.getShapes()
    console.log solution

    api.put.correction @correction().id, solution
    .then =>
      @isSaving false
      @isSaved true
    .catch =>
      @isSaving false

  resize: ->
    for page in @pages()
      actualWidth = page.canvas.width()
      page.canvas.parent().height actualWidth / page.width * page.height
      page.canvas.attr
        height: actualWidth / page.width * page.height
        width: actualWidth
      page.scribble.setScale actualWidth / page.width

fs = require 'fs'
module.exports = ->
  ko.components.register __filename.substr(__dirname.length, __filename.length - 7),
    template: fs.readFileSync __filename.substr(0, __filename.length - 7) + '.html', 'utf8'
    viewModel: ViewModel
  return __filename.substr(__dirname.length, __filename.length - 7)

# // In your Webpack config:
# //
# // Install `npm install url-loader` first.
# // This will enable you to get the url of the worker and the pdf to use in the index.js.
# // Notice that for the build process it might need some extra work.
# webpackConfig.module.loaders = {
#     test: /\.pdf$|pdf\.worker\.js$/,
#     loader: "url-loader?limit=10000"
# }
#
# // in index.js
# require('pdfjs-dist/build/pdf');
# require('pdfjs-dist/web/pdf_viewer'); // Only if you need `PDFJS.PDFViewer`
# // Webpack returns a string to the url because we configured the url-loader.
# PDFJS.workerSrc = require('pdfjs-dist/build/pdf.worker.js');
# var url = require('assets/books/my book.pdf');
# PDFJS.getDocument(url).then(function(pdf) {/* Continue the normal tutorial from the README.*/})
