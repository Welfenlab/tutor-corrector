
var express = require('express');
var _ = require('lodash');
var bcrypt = require('bcrypt-then');

// initialize the production environment
module.exports = function(config){
  console.log("production environment");
  config.database.host = process.env.RETHINKDB_PORT_28015_TCP_ADDR;
  config.database.port = parseInt(process.env.RETHINKDB_PORT_28015_TCP_PORT);
  var rethinkDB = require("@tutor/rethinkdb-database")(config);
  return rethinkDB.then(function(DB){
    restAPI = require("./rest")(DB);

    var tutorAuth = function(name, pw) {
      return DB.Users.authTutor(name, _.partial(bcrypt.compare,pw));
    };
    config.modules = []
    config.modules.push(require("@tutor/dummy-auth")(DB.Connection, DB.Rethinkdb, tutorAuth));
    config.domainname = "tutor-corrector.gdv.uni-hannover.de"

    config.modules.push(function(app){ app.use(express.static('./build')); });
    return restAPI;
  });
}
