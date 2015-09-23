
chai = require("chai");
chai.should();

var config = require("cson").load("./test/fixtures/config.cson");
var request = require("request");
var TutorServer = require("@tutor/server");


var memDB = require("@tutor/memory-database")();
var restoreDB = function(){
  memDB.Restore("./test/fixtures/db.json");
};
var restAPI = require("../src/rest")(memDB);
config.modules = [function(app,config){
  app.use(function(req,res,next){ req.session = {uid:"tutor"}; next() });
}];
config.log = {error:function(){},log:function(){}};
var server = TutorServer(config);

// register rest API
restAPI.forEach(function(rest){
  server.createRestCall(rest);
});
server.start()
var doSimpleRequest = function(method, path, data, fn){
  request({
    url: "http://"+config.domainname+":"+config.developmentPort+"/api"+path,
    method: method, //Specify the method
    form: data,
    headers: { //We can define headers too
        'Content-Type': 'MyContentType',
        'Custom-Header': 'Custom Value'
    }
  }, fn);
}
var doRequest = function(method,path,data,fn){
  if(typeof(data) == "function"){
    fn = data;
    data = null;
  }
  doSimpleRequest(method,path,data,function(err,res,body){
    var parsed = null;
    try{
      parsed = JSON.parse(body);
      fn(err,res,parsed);
    } catch(e){
      console.log("Error parsing body\n"+body);
      console.log(e);
      fn(e);
    }
  });
}

beforeEach(function(){
  restoreDB();
})

describe("Student REST API", function(){
  it("should return all exercises",function(done){
    doRequest("GET","/exercises",
      function(err, res, body){
        (err == null).should.be.true;
        body.should.have.length(2);
        res.statusCode.should.equal(200);
        done();
      });
  });
  it("list of exercises should not contain tasks",function(done){
    doRequest("GET","/exercises",
      function(err, res, body){
        (err == null).should.be.true;
        body.forEach(function(ex){
          ex.should.not.have.key("tasks");
        });
        done();
      });
  });

  it("returns a detailed list that should contain tasks", function(done){
    doRequest("GET", "/exercises/detailed/ee256059-9d92-4774-9db2-456378e04586",
      function(err, res, body){
        (err == null).should.be.true;
        body.tasks.forEach(function(t){
          (typeof(t)).should.equal("object");
        });
        res.statusCode.should.equal(200);
        done();
    });
  });

  it("should return the number of pending solutions", function(done){
    doRequest("GET", "/correction/pending/ee256059-9d92-4774-9db2-456378e04586",
      function(err, res, body){
        (err == null).should.be.true;
        body.should.equal(2);
        done();
    });
  });

  it("has a method for storing the result without finalizing", function(done){
    doSimpleRequest("PUT", "/correction/store", {id: "85ca34c0-61d6-11e5-97cb-685b35b5d746", results:[]},
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(204);
        done();
    });
  });

  it("should return the status of all corrections", function(done){
    doRequest("GET", "/correction",
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.should.have.length(2);
        body.should.deep.include.members([
          { exercise: 'ee256059-9d92-4774-9db2-456378e04586', solutions: 2, corrected: 0, locked: 1 },
          { exercise: 'f31ad341-9d92-4774-9db2-456378e04586', solutions: 0, corrected: 0, locked: 0 }
        ]);
        done();
    })
  });

  it("should (on demand) assign a new solution to the tutor", function(done){
    doRequest("GET", "/correction/next/ee256059-9d92-4774-9db2-456378e04586",
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.group.should.equal("fd8c6b08-572d-11e5-9824-685b35b5d746");
        done();
      }
    )
  });

  it("should list all unfinished corrections", function(done){
    doRequest("GET", "/correction/unfinished",
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.should.have.length(1);
        done();
    });
  });

  it("should finalize exercises for a tutor", function(done){
    doSimpleRequest("POST", "/correction/finish", {id: "85ca34c0-61d6-11e5-97cb-685b35b5d746"},
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(204);
        done();
    });
  });

  it("should be possible to get user information", function(done){
    doRequest("GET", "/tutor",
      function(err, res, body){
        (err == null).should.be.true;
        res.statusCode.should.equal(200);
        body.name.should.equal("tutor");
        body.should.not.have.key("pw");
        done();
    });
  });

});
