var express = require("express");

// initialize the development environment
module.exports = function(config){
  console.log("### development environment ###");
  var MemDB = require("@tutor/memory-database")(config);

  restAPI = require("./rest")(MemDB);

  var tutorExists = function(name) {
    return MemDB.Users.getTutor(name).then(function(user) {
      return user != null;
    });
  };
  config.modules = []
  config.modules.push(require("@tutor/dummy-auth")(tutorExists));
  config.domainname = "tutor-corrector.gdv.uni-hannover.de"
  //config.modules.push(require("@tutor/saml"));

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

  return new Promise(function(resolve){
    resolve(restAPI);
    open("http://localhost:"+config.developmentPort);
  });
}
