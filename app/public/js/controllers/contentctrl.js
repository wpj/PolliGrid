(function() {
  define(['underscore'], function(_) {
    return function($scope, Question, $window, $stateParams, $q, $timeout, $state) {
      var download;
      $scope.questions = Question.get();
      $scope.searchFocused = false;
      $scope.filteredQuestions = [];
      $scope.showLoader = false;
      $scope.isContentsLoaded = true;
      download = function() {
        var object;
        object = {
          id: 5,
          newOption: "",
          question: "Which one of the following best describes you best best describes you best describes you best describes you describes you",
          category: "Lifestyle",
          respondents: [8, 3, 2, 4, 5, 6, 7, 9],
          alreadyAnswered: false,
          numOfFavorites: 4,
          numOfFilters: 2,
          totalResponses: 8,
          created_at: 1398108220,
          creator: 1,
          creatorName: "Masanori",
          photo: "/img/users/profile-pic.jpg",
          option: [
            {
              title: 'positive',
              count: 5,
              answeredBy: [3, 2, 5, 8]
            }, {
              title: 'negative',
              count: 4,
              answeredBy: [4, 6, 7, 9]
            }
          ],
          targets: [
            {
              id: 1,
              title: "Age",
              question: "How old are you?",
              lists: [
                {
                  option: "~ 10",
                  answeredBy: [9]
                }, {
                  option: "11 ~ 20",
                  answeredBy: [2, 5]
                }, {
                  option: "21 ~ 30",
                  answeredBy: [3, 6, 7]
                }, {
                  option: "31 ~ 40",
                  answeredBy: [4, 8]
                }, {
                  option: "41 ~ 50",
                  answeredBy: []
                }, {
                  option: "51 ~ 60",
                  answeredBy: []
                }, {
                  option: "61 ~ ",
                  answeredBy: []
                }
              ]
            }, {
              id: 2,
              title: "Ethnicity",
              question: "What is your ethnicity?",
              lists: [
                {
                  option: "Asian",
                  answeredBy: [7, 9]
                }, {
                  option: "Hispanic",
                  answeredBy: [2]
                }, {
                  option: "Caucasian",
                  answeredBy: [3, 6, 8]
                }, {
                  option: "African-American",
                  answeredBy: [4, 5]
                }
              ]
            }
          ]
        };
        return $scope.questions.push(object);
      };
      $scope.downloadMoreContents = function() {
        var defer;
        $scope.showLoader = true;
        defer = $q.defer();
        defer.promise.then(function() {
          return download();
        }).then(function() {
          return $scope.showLoader = false;
        });
        return defer.resolve();
      };
      $scope.putCategory = function(category) {
        $scope.category = category;
        return $scope.searchFocused = false;
      };
      $scope.updateSearch = function() {
        return $scope.searchFocused = false;
      };
      $scope.sortBy = function(order) {
        $scope.questions = [];
        console.log(Question);
        return $timeout(function() {
          switch (order) {
            case "Recent":
              $scope.order = "Recent";
              return $scope.questions = _.sortBy(Question, function(object) {
                return -object.created_at;
              });
            case "Old":
              $scope.order = "Old";
              return $scope.questions = _.sortBy(Question, function(object) {
                return object.created_at;
              });
            case "Most voted":
              $scope.order = "Most voted";
              return $scope.questions = _.sortBy(Question, function(object) {
                return -object.totalResponses;
              });
            case "Most popular":
              $scope.order = "Most popular";
              return $scope.questions = _.sortBy(Question, function(object) {
                return -object.numOfFavorites;
              });
          }
        }, 100, true);
      };
      return $scope.$apply();
    };
  });

}).call(this);
