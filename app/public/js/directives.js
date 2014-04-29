(function() {
  define(['angular', 'controllers', 'underscore'], function(angular, controllers, _) {
    return angular.module('myapp.directives', ['myapp.controllers', 'myapp.services']).directive('newFilter', function() {
      return {
        restrict: 'EA',
        scope: true,
        templateUrl: 'views/partials/newfilter.html',
        controller: 'NewFilterCtrl'
      };
    }).directive('stopEvent', function() {
      return {
        restrict: 'A',
        link: function(scope, element, attr) {
          return element.bind(attr.stopEvent, function(e) {
            return e.stopPropagation();
          });
        }
      };
    }).directive('buttonOk', function($timeout) {
      return {
        restrict: 'A',
        scope: {
          question: "=buttonOk",
          target: "=",
          filterAdded: "="
        },
        link: function(scope, elem) {
          return $timeout(function() {
            var addedFilter, targetIds;
            targetIds = _.pluck(scope.question.targets, 'id');
            addedFilter = _.find(targetIds, function(id) {
              return Number(id) === Number(scope.target.id);
            });
            if (addedFilter) {
              return scope.filterAdded = true;
            }
          }, 100, true);
        }
      };
    }).directive('answered', function($timeout) {
      return {
        restrict: "A",
        scope: {
          answered: "=",
          submitted: "="
        },
        link: function(scope) {
          return $timeout(function() {
            if (scope.answered.alreadyAnswered) {
              return scope.submitted = true;
            }
          }, 500, true);
        }
      };
    }).directive('favorited', function($timeout, User) {
      return {
        restrict: "A",
        scope: {
          question: "=favorited",
          favorite: "="
        },
        link: function(scope) {
          return $timeout(function() {
            var favoriteQuestion;
            favoriteQuestion = _.find(User.favorites, function(id) {
              return Number(id) === Number(scope.question.id);
            });
            if (favoriteQuestion) {
              return scope.favorite = true;
            }
          }, 550, true);
        }
      };
    }).directive('focusMe', function($timeout) {
      return {
        restrict: "A",
        scope: {
          focusMe: "="
        },
        link: function(scope, element) {
          return $timeout(function() {
            return element.bind('focus', function() {
              return scope.$apply(scope.focusMe = true);
            });
          }, 300, true);
        }
      };
    }).directive("reset", function($timeout, $window) {
      return {
        restrict: "A",
        scope: {
          reset: "="
        },
        link: function(scope, element, attr) {
          var w;
          w = angular.element($window);
          return w.bind("click", function(e) {
            switch (e.target.id) {
              case 'categorybox':
              case 'searchbox':
              case "category-select":
              case "order-select":
                return scope.$apply(scope.reset = true);
              default:
                return scope.$apply(scope.reset = false);
            }
          });
        }
      };
    });
  });

}).call(this);
