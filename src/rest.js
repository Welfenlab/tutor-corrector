
module.exports = function(DB){
  return [
    { path: '/api/exercises', dataCall: DB.Exercises.get, apiMethod: "get" },
    { path: '/api/exercises/:id', dataCall: DB.Exercises.getById, apiMethod: "getByParam", param: "id", errStatus: 404  },

    { path: '/api/correction/pending/:id', dataCall: DB.Corrections.getNumPending,
      apiMethod: "getByParam", param: "id", errStatus: 404  },
    { path: '/api/correction', dataCall: DB.Corrections.getStatus, apiMethod: "get" },
    { path: '/api/correction/next/:id', dataCall: DB.Corrections.lockNextSolutionForTutor,
      apiMethod: "getBySessionUIDAndParam", param: "id", errStatus: 404 },
    { path: '/api/correction/finish', dataCall: DB.Corrections.finishSolution,
      apiMethod: "postBySessionUIDAndParam", param: "id", errStatus: 404 },
    { path: '/api/correction/unfinished', dataCall: DB.Corrections.getUnfinishedSolutionsForTutor,
      apiMethod: "getBySessionUID" },
      { path: '/api/correction/finished', dataCall: DB.Corrections.getFinishedSolutionsForTutor,
        apiMethod: "getBySessionUID" },
    { path: '/api/correction/store', dataCall: DB.Corrections.setResultForExercise,
      apiMethod: "putBySessionUIDAndParams", params: ["id", "results"], errStatus: 404 },

    { path: '/api/tutor', dataCall: DB.Users.getTutor, apiMethod: "getBySessionUID" },

    { path: '/api/solution/:id', dataCall: DB.Exercises.getExerciseSolution,
      apiMethod: "getBySessionUIDAndParam", param: "id", errStatus: 404 },
  ];
};
