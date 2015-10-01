address = 'http://localhost:8080/api'
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
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
  post:
    login: (username, password) -> post "/login",
        id: username,
        password: password

module.exports = api
