{get, put, post, del, address} = require('@tutor/app-base').api

api =
  get:
    exercises: -> get('/exercises')
    exercise: (id) -> get("/exercises/#{id}")
    overview: -> get('/correction')
    me: -> get('/tutor')
    pdf: (id) -> get("/correction/pdf/#{id}")
    nextSolution: (exercise) -> get "/correction/next/#{exercise}"
    solution: (id) -> get "/solution/#{id}"
    unfinishedCorrections: -> get '/corrections/unfinished'
  put:
    exercise: (id, content) -> put "/exercises/#{id}", content
    correction: (id, results) -> put "/correction/store",
      solution: id
      results: results
    finalizeCorrection: (id) -> put "/correction/finalize",
      solution: id
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
