
var express = require('express');
var _ = require('lodash');
var bcrypt = require('bcrypt-then');

// initialize the production environment
module.exports = function(config){
  console.log("production environment");
  config.database.host = process.env.RETHINKDB_PORT_28015_TCP_ADDR;
  config.database.port = parseInt(process.env.RETHINKDB_PORT_28015_TCP_PORT);
  config.sharejs = config.sharejs || {}
  config.sharejs.rethinkdb = config.sharejs.rethinkdb || {}
  console.log("... waiting 10s for RethinkDB");
  config.database.host = process.env.RETHINKDB_PORT_28015_TCP_ADDR;
  config.database.port = parseInt(process.env.RETHINKDB_PORT_28015_TCP_PORT);
  config.sharejs.rethinkdb.host = config.database.host;
  config.sharejs.rethinkdb.port = config.database.port;
  var rethinkDB = require("@tutor/rethinkdb-database")(config);
  return rethinkDB.then(function(DB){
    restAPI = require("./rest")(DB);

    config.domainname = "tutor-corrector.gdv.uni-hannover.de"


    var tutorAuth = function(name, pw) {
      return DB.Users.authTutor(name, _.partial(bcrypt.compare,pw));
    };
    config.modules = []
    config.modules.push(require("@tutor/auth")(DB.Connection, DB.Rethinkdb, tutorAuth));
    config.modules.push(function(app){ app.use(express.static('./build')); });
    
    return restAPI;
  });
}
