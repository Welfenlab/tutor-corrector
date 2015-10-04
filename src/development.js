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
    config.modules.push(require("@tutor/dummy-auth")(tutorAuth));
    config.domainname = "tutor-corrector.gdv.uni-hannover.de"

    config.modules.push(function(app, config){
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

  // development server with memory database
  if(!config.devrdb){
    console.log("### development environment ###");
    var MemDB = require("@tutor/memory-database")(config);
    restAPI = require("./rest")(MemDB);
    return new Promise(function(resolve){
      configureServer(restAPI, MemDB);
      resolve(restAPI);
      open("http://localhost:"+config.developmentPort);
    });
  } else { // development server with rethinkdb database
    console.log("### development environment with RethinkDB @" +
      config.database.host + ":" + config.database.port + "/" + config.database.name + " ###")
    var rethinkDB = require("@tutor/rethinkdb-database")(config);
    return rethinkDB.then(function(DB){
      restAPI = require("./rest")(DB);
      configureServer(restAPI, DB);
      return restAPI;
    });
  }
}
