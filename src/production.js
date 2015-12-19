
var bcrypt = require("bcrypt-then");
var _ = require('lodash')

// initialize the production environment
module.exports = function(app, config){
  console.log("production environment");
  console.log("... waiting 10s for RethinkDB");
  config.database.host = process.env.RETHINKDB_PORT_28015_TCP_ADDR;
  config.database.port = parseInt(process.env.RETHINKDB_PORT_28015_TCP_PORT);
  config.sharejs.rethinkdb.host = config.database.host;
  config.sharejs.rethinkdb.port = config.database.port;
  var rethinkDB = require("@tutor/rethinkdb-database")(config);

  var restAPI = require("./rest")(rethinkDB);

  var tutorAuth = function(name, pw) {
    return rethinkDB.Users.authTutor(name, _.partial(bcrypt.compare,pw));
  };
  config.modules = []
  config.modules.push(require("@tutor/auth")(rethinkDB.Connection, rethinkDB.Rethinkdb, tutorAuth));

  return new Promise(function(resolve){
    resolve(restAPI);
  });
}
