
module.exports = function(DB){
  return [
    { path: '/api/exercises', dataCall: DB.Exercises.getExercises, apiMethod: "get" },
    { path: '/api/exercises/detailed/:id', dataCall: DB.Exercises.getExercise, apiMethod: "getByParam", param: "id", errStatus: 404  },

    { path: '/api/correction/pending/:id', dataCall: DB.Correction.getNumPending, apiMethod: "getByParam", param: "id", errStatus: 404  },
    { path: '/api/correction', dataCall: DB.Correction.status, apiMethod: "get" },
    { path: '/api/correction/next/:id', dataCall: DB.Correction.lockNextSolutionForTutor, apiMethod: "getBySessionUIDAndParam", param: "id", errStatus: 404 },

    { path: '/api/solution/:id', dataCall: DB.Exercises.getExerciseSolution, apiMethod: "getBySessionUIDAndParam", param: "id", errStatus: 404 },
  ];
};
