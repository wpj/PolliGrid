define ['angular','controllers','underscore','jquery'], (angular,controllers,_,$) ->
	angular.module('myapp.directives', ['myapp.controllers','myapp.services'])

		.directive 'newFilter',()->
			restrict 	: 'EA'
			scope 		: true
			templateUrl : 'views/partials/newfilter.html'
			controller 	: 'NewFilterCtrl'
		
		.directive 'stopEvent', ()->
	        
			restrict: 'A'
			link: (scope, element, attr) ->
				element.bind attr.stopEvent, (e)->
					e.stopPropagation()




		# this will check if target question is already added to the question
		.directive 'buttonOk', ($timeout)->
	        
			restrict 	: 'A'
			scope 		:{
				question 	: "=buttonOk"
				target 		: "="
				filterAdded : "="

			}
			link		: (scope,elem)->
				
				$timeout ()->
					
					# if the target question is already added to the question
					# change the button looks
					targetIds = _.pluck scope.question.targets,'_id'
									
					addedFilter = _.find targetIds, (id)->
						id == scope.target._id

					if addedFilter
						scope.filterAdded = true
						
				,100,true 


		.directive 'answered', ($timeout)->

			restrict : "A"
			scope:{
				answered  	: "="
				submitted 	: "="
			}
			link : (scope)->
				
				$timeout ()->
					
					if scope.answered 
						
						scope.submitted = true
					
				
				,500,true      

	


		.directive 'favorited', ($timeout,User)->

			restrict : "A"
			scope:{
				question 		: "=favorited"
				favorite 		: "="
			}
			link : (scope)->
				
				$timeout ()->
					
					if scope.question != undefined and User.user
						
						favoriteQuestion = _.find User.user.favorites, (id)->
							
							id == scope.question._id

					if favoriteQuestion
						scope.favorite = true
						
				,100,true 

		.directive 'focusMe', ($timeout)->

			restrict : "A"
			scope:{
				focusMe : "="
			}
			link : (scope,element)->
				$timeout ->
					
					element.bind 'focus', ->	
						scope.$apply(scope.focusMe = true)

				,300,true

		.directive "toggle", ($timeout,$window)->
			restrict: "A"
			scope: {
				order : "="
				category : "="
			}
			link: (scope, element,attr)->
				
				w = angular.element($window)
				w.bind "click", (e)->
					
					if e.target.id == "order-toggler" || e.target.id == "order-icon"
						
						scope.$apply(scope.category = false)

					else if e.target.id == "category-toggler" || e.target.id == "category-icon"
						
						scope.$apply(scope.order = false)
					
					else
					
						scope.$apply(scope.order = false)
						scope.$apply(scope.category = false)
			
		.directive "getSize", ($timeout)->
			restrict:"A"
			scope:{
				getSize:"="
			}
			link:(scope,elem)->
				
				$timeout ->
					scope.getSize.height = elem[0].offsetHeight
					scope.getSize.width  = elem[0].offsetWidth
				,300,true

		.directive "disableEnter", ->
			(scope, element, attrs) ->
				element.bind "keydown keypress", (event) ->
					if event.which is 13
						event.preventDefault()
		

		


		# same as ng-repeat except for these don't create new scopes
		.directive 'noScopeRepeatForGrid', ($compile,$templateCache)->
			link: (scope, elem, attrs)->
				scope.$watch attrs.items,(items)->
					if items
						template = $templateCache.get("question.html")


						items.forEach (val, key)->
							newElement = angular.element(template.replace(/#OBJ#/g, attrs.items + '[' + key + ']'))
							$compile(newElement)(scope);
							elem.append(newElement);

		.directive 'noScopeRepeatForTargets', ($compile,$templateCache)->
			link: (scope, elem, attrs)->
				scope.$watch attrs.items,(items)->
					if items

						# ng-show=\"$index==filterNumber\"
						template = $templateCache.get('targetQuestion.html')







						items.forEach (val, key)->
							# key will play a role of index
							starting = "<div class=\"content animated fadeInLeft\" ng-show=\""+key+"==filterNumber\">"
							closing = "	<form ng-controller=\"TargetListCtrl\" ng-submit=\"submitTarget(card,targetAnswer,"+key+")\">
											<ul no-scope-repeat-for-targets-options items=\"#OBJ#.lists\" class=\"answers\"></ul>
											<input type=\"submit\" class=\"submit-button btn btn-primary btn-sm\" value=\"Next\">
										</form>
									</div>"



							newTemplate = starting.concat(template,closing)

							
							newElement = angular.element(newTemplate.replace(/#OBJ#/g, attrs.items + '[' + key + ']'))
							
							$compile(newElement)(scope)
							elem.append(newElement)

							

							
							
							
		
		.directive 'noScopeRepeatForTargetsOptions', ($compile,$templateCache)->
			link: (scope, elem, attrs)->
				scope.$watch attrs.items,(items)->
					if items

						# ng-show=\"$index==filterNumber\"
						template = $templateCache.get('targetQuestion-options.html')



						items.forEach (val, key)->
							newElement = angular.element(template.replace(/#OBJ#/g, attrs.items + '[' + key + ']'))
							$compile(newElement)(scope)
							elem.append(newElement)



		.directive 'noScopeRepeatForCounts', ($compile,$templateCache)->
			link: (scope, elem, attrs)->
				scope.$watch attrs.items,(items)->
					if items

						# ng-show=\"$index==filterNumber\"
						template = $templateCache.get('result.html')



						items.forEach (val, key)->
							newElement = angular.element(template.replace(/#OBJ#/g, attrs.items + '[' + key + ']'))
							$compile(newElement)(scope)
							elem.append(newElement)
					



