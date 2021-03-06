define ['angular'], (angular) ->
	angular.module('myapp.services', ['ngResource'])
		.factory 'Filters', ($resource)->
			$resource(
				"/api/filter/:searchTerm/:offset"
				{
					offset 		: "@offset"
					searchTerm 	: "@searchTerm"
				}
				{
					"save":
						method:"POST"
						params:
							offset:"0"
							searchTerm:"new"
						
					
					"get":
						method:"GET"
						isArray:true
					
				}
			)

		.factory 'FilterTypeHead', ($resource)->
			$resource(
				"/api/getFilterTitle/:term"
				{
					term:"@term"
				}
				{
					"get":
						method:"GET"
						isArray:true
				}
			)
				
		.factory 'Question', ($resource)->
			$resource(
				"/api/question/:questionId/:action"
				{
					questionId:"@questionId"
					action:"@action"
				}
				{
					"get" :
						method: "GET"
						params :
							action : 0
					
					"save" :
						method : "POST"
						params :
							questionId : 0
							action 	   : 0

					"favorite" :
						method : "PUT"

				}
			)

		.factory 'UpdateQuestion',($resource)->
			$resource(
				"/api/updateQuestion/:questionId/:userId/:visitorId/:title/:filterId/:index/:task"
				{
					questionId 	: "@questionId"
					userId 		: "@userId"
					visitorId 	: "@visitorId"
					title 		: "@title"
					filterId 	: "@filterId"
					index 		: "@index"
				}
				{
					"updateQuestion":
						method 		: "PUT"
						params 		:
							visitorId 	: 0
							task 		: "update"
					
					"updateFilters" :
						method 		: "PUT"
						params 		:
							visitorId 	: 0
							task  		: "update"
					
					"removeFiltersAnswer":
						method 		: "PUT"
						params 		:
							task  	: "removeFilter"
					"removeAnswer"  : 
						method 		: "PUT"
						params 		:
							task  	: "remove"
							
				}
			)

		.factory 'QuestionTypeHead', ($resource)->
			$resource(
				"/api/getQuestionTitle/:term/:category"
				{
					term:"@term"
					category:"@category"
				}
				{
					"get":
						method:"GET"
						isArray:true
				}
			)

		.factory 'FindQuestions', ($resource)->
			$resource(
				"/api/findQuestions/:searchTerm/:category/:order/:offset"
				{
					searchTerm 	: "@searchTerm"
					category 	: "@category"
					order 		: "@order"
					offset 		: "@offset"
				}
				{

					"get":
						method:"GET"
						isArray:true

					"default":
						method:"GET"
						params:
							searchTerm 	: "All"
							category 	: "All"
							order 		: "Recent"
							offset 		: 0
						isArray:true
					
				}
			)

		.factory "FindByType", ($resource)->
			$resource(
				"/api/findQuestionsBy/:userId/:type"
				{
					userId:"@userId"
					type:"@type"
				}
				{
					"get":
						method:"GET"
						isArray:true
				}
			)
			

		.factory 'UpdateUserInfo',($resource)->
			$resource(
				"/api/updateUser/:userId/:qId/:qAnswer/:fId/:fAnswer/:task"
				{
					userId 	: "@userId"
					qId 	: "@questionId"
					qAnswer : "@questionAnswer"
					fId 	: "@filterId"
					fAnswer : "@filterAnswer"
					task 	: "@task"
				}
				{
					"answerQuestion":
						method:"PUT"
						params:
							task 	: "updateQuestion"
							fId 	: 0 
							fAnswer : 0
					
					"answerFilter":
						method:"PUT"
						params:
							task 	: "updateFilter"
							qId 	: 0
							qAnswer : 0
					
					"changeFilter":
						method:"PUT"
						params:
							task 	: "changeFilter"
							qId 	: 0
							qAnswer : 0

					"favorite":
						method:"PUT"
						params:
							qAnswer : 0
							fId 	: 0
							fAnswer : 0

					"reset":
						method:"PUT"
						params:
							qAnswer : 0
							fId 	: 0
							fAnswer : 0
							task 	: "reset"

				}

			)

	
		.factory 'User', (ipCookie,$http,$q,$rootScope,$timeout)->
			
			# get the unique id
			randLetter = String.fromCharCode(65 + Math.floor(Math.random() * 26))
			uniqid = randLetter + Date.now()
			
			console.log loggedInUser = ipCookie("loggedInUser")

			# get updated loggedInUser
			if loggedInUser
				$http 

					url 	: "/api/getUser"
					method 	: "GET"
					params 	: {userId: loggedInUser._id}

				.success (data)-> 
					
					defer = $q.defer()
					defer.promise 
						.then ->
							_.each data.targetQuestionsAnswered,(list)->
								list.answer = unescape(list.answer)
						.then ->
							# update user information
							data.isLoggedIn = true
							loggedInUser = data
							user.user = data
					defer.resolve()
			
			user = 	
				visitor: 
						_id						: uniqid
						name  					: 'visitor'
						favorites 				: []
						isLoggedIn 				: false
						questionsAnswered 		: []
						filterQuestionsAnswered : []
				
				user : loggedInUser
				answer:null
				checkState :  ->
					$rootScope.$broadcast 'userLoggedIn',"main"




		.factory "Account",($rootScope,$timeout)->
			verifiedMessage: (message,result)->
				$rootScope.account =
					message : '' 
					success : false
					fail 	: false
					resetPass:false
				$rootScope.account.message = message

				
				if result == 'success'
					
					$rootScope.account.success = true
					
					
				else if result == 'fail'
					$rootScope.account.fail = true


				$timeout ->
					$rootScope.account.message = ""
					$rootScope.account.success = false
					$rootScope.account.fail = false
				,3000,true




		.factory 'Verification',($resource)->
			$resource(
				"/api/user/:id/:email/:task/:pass"
				{
					id:"@id"
					email:"@email"
					pass:"@pass"
				}
				{
					
					"findUserById":
						method 	: "GET"
						params 	:
							email : 0
							task  : "findById"
							pass  : "0"
						

					
					"findUserByEmail":
						method 	: "GET"
						params 	:
							id 	: 0
							task  : "findByEmail"
							pass  : "0"
						isArray:true

					"checkPass":
						method 	: "GET"
						params 	:
							id 		: 0
							task  	: "checkPass" 
						isArray : false
	
				}
			)

		.factory "Password",($resource)->
			$resource(
				"/api/resetPass/:email/:pass"
				{
					email:"@email"
					pass:"@pass"
				}
				{
					"reset":
						method:"POST"
				}
			)


		.factory 'Error', ()->
			error = 
				auth : ""

		.factory 'Setting', ()->
			page = 
				isSetting 	: false
				questionId	: null
				section 	: null

		.factory 'Page', ()->
			page = 
				questionPage 	: 0
				filterPage 		: 0

		.factory 'Search', ()->
			search = 
				category 	: "All"

		.factory 'NewQuestion', ()->
			question = 
				question 	: ""

				


		# Create an AngularJS service called debounce
		.factory "Debounce", ($timeout, $q) ->
    
			# The service is actually this function, which we call with the func
			# that should be debounced and how long to wait in between calls
			return debounce = (func, wait, immediate) ->
				timeout = undefined

				# Create a deferred object that will be resolved when we need to
				# actually call the func
				deferred = $q.defer()
				->
					context = this
					args = arguments
					later = ->
						timeout = null
						unless immediate
							deferred.resolve func.apply(context, args)
							deferred = $q.defer()
							return

					callNow = immediate and not timeout
					$timeout.cancel timeout  if timeout
					timeout = $timeout(later, wait)
					if callNow
						deferred.resolve func.apply(context, args)
						deferred = $q.defer()
					deferred.promise
		
		.factory "location", ($location, $route, $rootScope) ->
			page_route = $route.current
			$location.skipReload = ->
				
				#var lastRoute = $route.current;
				unbind = $rootScope.$on("$locationChangeSuccess", ->
					$route.current = page_route
					unbind()
					return
				)
				$location

			throw "$location.intercept is already defined"  if $location.intercept
			$location.intercept = (url_pattern, load_url) ->
				parse_path = ->
					match = $location.path().match(url_pattern)
					if match
						match.shift()
						match
				unbind = $rootScope.$on("$locationChangeSuccess", ->
					matched = parse_path()
					return unbind()  if not matched or load_url(matched) is false
					$route.current = page_route
					return
				)
				return

			return $location
		