
var fs = require("fs");
var path = require("path");

module.exports = function(DB){
  return [
    { path: '/api/exercises', dataCall: DB.Exercises.get, apiMethod: "get" },
    { path: '/api/exercises/:id', dataCall: DB.Exercises.getById, apiMethod: "getByParam", param: "id", errStatus: 404  },

    { path: '/api/correction/pending/:exercise', dataCall: DB.Corrections.getNumPending,
      apiMethod: "getByParam", param: "exercise", errStatus: 404  },
    { path: '/api/correction', dataCall: DB.Corrections.getStatus, apiMethod: "getBySessionUID" },
    { path: '/api/correction/next/:exercise', dataCall: DB.Corrections.lockNextSolutionForTutor,
      apiMethod: "getBySessionUIDAndParam", param: "exercise", errStatus: 404 },
    { path: '/api/correction/pdf/:solution', dataCall: function(solution_id, res){
      return DB.Corrections.getPDFForID(solution_id).then(function(pdf){
        res.setHeader('Content-disposition', 'attachment; filename=' + solution_id + '.pdf');
        res.setHeader('Content-type', 'application/pdf');
        if(pdf && pdf != "" && false){
          res.send(pdf);
        } else {
          res.send(fs.readFileSync(path.normalize(__dirname + "/../test.pdf")));
        }
      });
    }, apiMethod: "getResByParam", param:"solution" },,
    { path: '/api/correction/finish', dataCall: DB.Corrections.finishSolution,
      apiMethod: "postBySessionUIDAndParam", param: "solution", errStatus: 404 },
    { path: '/api/correction/unfinished/:exercise', dataCall: DB.Corrections.getUnfinishedSolutionsForTutor,
      apiMethod: "getBySessionUIDAndParam", param: "exercise" },
      { path: '/api/correction/finished/:exercise', dataCall: DB.Corrections.getFinishedSolutionsForTutor,
        apiMethod: "getBySessionUIDAndParam", param: "exercise" },
    { path: '/api/correction/store', dataCall: DB.Corrections.setResultForExercise,
      apiMethod: "putBySessionUIDAndParams", params: ["solution", "results"], errStatus: 404 },

    { path: '/api/tutor', dataCall: DB.Users.getTutor, apiMethod: "getBySessionUID" },

    { path: '/api/solutions/by/user/:user', dataCall: DB.Corrections.getUserSolutions,
      apiMethod: "getByParam", param: "user" },
    { path: '/api/solution/for/user/:user/exercise/:exercise', dataCall: DB.Corrections.getUserExerciseSolution,
        apiMethod: "getByParams", params: ["user","exercise"] },
    { path: '/api/solution/:id', dataCall: DB.Exercises.getExerciseSolution,
      apiMethod: "getBySessionUIDAndParam", param: "id", errStatus: 404 },
    { path: '/api/corrections/unfinished', dataCall: DB.Corrections.getUnfinishedSolutionsForTutor,
      apiMethod: "getBySessionUID" }
  ];
};
