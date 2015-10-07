host = window.location.host.toString().split(":");
port = host[1].split("/")[0];
address = "http://#{host[0]}:#{port}/api"
Q = require 'q'

ajax = (method, url, data) ->
  Q $.ajax
    url: address + url
    data: data
    method: method

get = ajax.bind undefined, 'GET'
put = ajax.bind undefined, 'PUT'
post = ajax.bind undefined, 'POST'
del = ajax.bind undefined, 'DELETE'

api =
  get:
    exercises: -> get('/exercises')
    exercise: (id) -> get("/exercises/#{id}")
    overview: -> get('/correction')
    me: -> get('/tutor')
    pdf: (id) -> get("/correction/pdf/#{id}")
    pendingCorrections: (exercise) -> get "/correction/pending/#{exercise}"
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
    correction: (id, results) -> put "/correction/store",
      id: id
      results: results
  post:
    login: (username, password) -> post "/login",
        id: username,
        password: password
    logout: -> post '/logout'
    correction: (id, correction) ->
      post ""
  urlOf:
    pdf: (id) -> "#{address}/correction/pdf/#{id}"

module.exports = api
