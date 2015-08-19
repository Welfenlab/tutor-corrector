ko = require 'knockout'
require 'pdfjs-dist/build/pdf.combined' #defines PDFJS globaly
#PDFJS.workerSrc = false
sketchjs = require 'sketch.js'
api = require '../../api'

class ViewModel
  constructor: ->
    if not $? then console.error 'No jQuery defined'
    if not $.fn.sketch then sketchjs($)

    @pageCount = ko.observable 0
    @page = ko.observable 0
    @imgData = ko.observable ''

    $('#correctionCanvas').sketch()
    @sketch = $('#correctionCanvas').sketch()
    window.addEventListener 'resize', => @resize()

    PDFJS.getDocument('http://localhost:8080/scripts/pages/correction/pdf-sample.pdf').then (pdf) =>
      @pageCount pdf.numPages

      pdf.getPage(1).then (page) =>
        #create an off-screen canvas for rendering the pdf
        canvas = document.createElement('canvas')
        ctx = canvas.getContext('2d')

        #get pdf size and set canvas size accordingly
        viewport = page.getViewport(2.0) #2.0 is the zoom level
        canvas.width = viewport.width
        canvas.height = viewport.height

        #render the page and put it into an image
        page.render({canvasContext: ctx, viewport: viewport}).then =>
          @imgData canvas.toDataURL()
          canvas.remove()
          @resize()

  resize: ->
    $('#correctionPage').height($('#correctionBg').height())
    $('#correctionCanvas').height($('#correctionBg').height())


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
