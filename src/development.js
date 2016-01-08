var express = require("express");
var bcrypt = require("bcrypt-then");
var _ = require("lodash");

// initialize the development environment
module.exports = function(config){
  var configureServer = function(API, DB) {
    var tutorAuth = function(name, pw) {
      return DB.Users.authTutor(name, _.partial(bcrypt.compare,pw));
    };
    config.modules = []
    config.modules.push(require("@tutor/auth")(DB.Connection, DB.Rethinkdb, tutorAuth));
    config.domainname = "tutor-corrector.gdv.uni-hannover.de"

    config.modules.push(function(app){
      app.use(express.static('./build'));
      // enable cors for development (REST API over Swagger)
      app.use(function(req, res, next) {
        res.header("Access-Control-Allow-Origin", "*");
        res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        next();
      });
      app.use(require('morgan')('dev'));
    });
  };

  console.log("### development environment with RethinkDB @" +
    config.database.host + ":" + config.database.port + "/" + config.database.name + " ###")
  var rethinkDB = require("@tutor/rethinkdb-database")(config);
  return rethinkDB.then(function(DB){
    var restAPI = require("./rest")(DB);
    configureServer(restAPI, DB);
    return restAPI;
  });
}
