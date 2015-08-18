address = 'http://localhost:8080/api'

ajax = (method, url, data) ->
  $.ajax
    url: address + url
    data: data
    method: method

get = (u, d, c) -> ajax 'GET', u, d
put = (u, d, c) -> ajax 'PUT', u, d
post = (u, d, c) -> ajax 'POST', u, d
del = (u, d, c) -> ajax 'DELETE', u, d

api =
  get:
    exercises: (c) -> get('/exercises', c)
    exercise: (id, c) -> get("/exercises/#{id}", c)
  put:
    exercise: (id, content, c) -> put "/exercises/#{id}", content
  post:
    login: (username, password) -> post "/login",
        username: username,
        password: password

module.exports = api
