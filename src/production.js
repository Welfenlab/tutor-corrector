

// initialize the production environment
module.exports = function(app, config){
  console.log("production environment");
  var rethinkDB = require("@tutor/rethinkdb-database")(config);

  restAPI = require("./rest")(rethinkDB);

  var tutorAuth = function(name, pw) {
    return MemDB.Users.authTutor(name, _.partial(bcrypt.compare,pw));
  };
  config.modules = []
  config.modules.push(require("@tutor/dummy-auth")(tutorAuth));

  return new Promise(function(resolve){
    resolve(restAPI);
  });
}
