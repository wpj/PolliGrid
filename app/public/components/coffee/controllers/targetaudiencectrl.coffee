define ['underscore'], (_)->
	($scope,$timeout,$q,Question,User)->

		# ------------------ Utility functions ------------------ #		
		
		# check to see if all the filter question is answered
		checkFilterQuestionStatus = (answer)->
			defer = $q.defer()
			defer.promise
				.then -> makeTargetChecker(answer)
				.then -> skipThroughFilterQuestions()
				.then -> checkIfEverythingAnswered()
			defer.resolve()

		# this will determine which filter question is not answered
		makeTargetChecker = (answer)->
			
			#cleans up the checker first
			$scope.targetChecker = []
			
			
			# get how many filter questions the question has
			if $scope.card != undefined
			
				length = $scope.card.targets.length
				i=0


				# get which question the user already answered to
				answeredIds = _.pluck $scope.user.filterQuestionsAnswered, 'id'

			if length 						
				while i < length
					
					questionId = Number($scope.card.targets[i].id)

					# find out if the question has filter questions, which
					# the user already answered to
					foundId = _.find answeredIds, (id)->
						Number(id) == questionId

					# if found, then this filter question won't show up
					if foundId
						
						#this will be used to show if the user already answered to the filter question	
						target  =
							id 			: foundId
							isAnswered 	: true



					# if not found, then this filter question will show up
					else 


						#this will be used to show if the user already answered to the filter question	
						target  =
							id 			: questionId
							isAnswered 	: false


					# after determining if the filter question is answered
					# add it to the targetChecker object
					$scope.targetChecker.push(target)

					i++

				console.count "makeTargetChecker was called :"
				console.log $scope.targetChecker
				

				return $scope.targetChecker

		# determine the initial filter questions
		# increment filterNumber until it hits the unanswered filter question
		skipThroughFilterQuestions = ()->

			#initial number
			$scope.filterNumber = 0
			
			length = $scope.targetChecker.length
			i = 0
			
			# keep skipping the filter question until it hits 
			# the question which has not been answered.
			while i < length
				
				if $scope.targetChecker[i].isAnswered
					
					# put the user's id into 
					# the array of question target lists's answeredBy array
					matchedOption = null

					# loop through the already answered target questions
					_.each $scope.user.filterQuestionsAnswered,(answer,index)->
						
						# if any of the answered question matched, store the object into the variable 
						matchedOption = _.find $scope.card.targets[i].lists,(list)->
							list.option == answer.answer
					
						# if the variable contains the matched object
						if matchedOption
						
							# and if the variable contains the user id
							if !_.contains(matchedOption.answeredBy,$scope.user.id)
							
								matchedOption.answeredBy.push($scope.user.id)

		

					# skip the problem
					$scope.filterNumber++
									
					

				else
					
					break

				i++

			
			return $scope.filterNumber
				

		# check if all of the filter question is answered
		checkIfEverythingAnswered = ()->
			
			length = $scope.targetChecker.length
			i=0
			numOfAnswers = 0



			while i < length
				

				if $scope.targetChecker[i].isAnswered
					numOfAnswers++ 
					
				i++


			
			
			# if the number of filter questions and 
			# number of filter questions answered
			# make allQuestionAnswered true, which show the result section
			if numOfAnswers == length

				console.log "numOfAnswers"
				console.log numOfAnswers
				console.log "length "
				console.log length 

				$scope.areAllQuestionAnswered = true
				$scope.filterNumber = -1
				

		
			

		


		# check if the question is already answered by the user
		# checkIfQuestionAlaredyAnswered = ()->
			
		# 	found = _.pluck $scope.user.questionsAnswered,'id'

		# 	isThisQuestionAnswered = _.find found, (id)->
		# 		if $scope.card is not undefined
		# 			id == $scope.card.id

		# 	if isThisQuestionAnswered
				
		# 		$scope.card.alreadyAnswered = true		


		# ------------------ Scope variables ------------------ #
			
		$scope.showResult = false
		
		$scope.areAllQuestionAnswered = false


		# this will show and hide specific filter questions
		$scope.filterNumber = 0
		

		# target filter answered or not
		$scope.targetChecker =[]
		

		# inital loading - to show results of the questions users already answered
		do ()->

			checkFilterQuestionStatus('')
			# checkIfQuestionAlaredyAnswered()
			#skipThroughFilterQuestions()
			

		# ------------------ Scope funcitons ------------------ #
		
		$scope.submitTarget = (question,targetAnswer,index)->
			

			# warning message pops up if users didn't choose any answer
			if targetAnswer is "" or !targetAnswer
			
				$scope.warning = true

			else

				# remove the warniing popup since the user selected something
				$scope.warning = false

				# this will get the id of the target audience question.
				targetQuestionID = question.targets[index].id

				# user's answer to the target question
				answer = 
					id 		: targetQuestionID
					answer 	: targetAnswer
				
				# find the answered option
				answeredOption = _.findWhere question.targets[index].lists,{option:targetAnswer}				
				answeredOption.answeredBy.push($scope.user.id)

				# add the answered filter question to the user's filterQuestionsAnswered collection
				# this way, the same filter question won't show up from the next time
				
				$scope.user.filterQuestionsAnswered.push(answer)

				
				defer = $q.defer()
				defer.promise
					
					.then ->

						checkFilterQuestionStatus(answer)

					.then ->
					
						# skip the filter question which is already answered
						skipThroughFilterQuestions()
							
						console.log $scope.areAllQuestionAnswered

						# if everything is answered, show result
						if $scope.areAllQuestionAnswered
							

							# by making this true, the question will show result from the next time
							# without answering.
							$scope.card.alreadyAnswered = true




				defer.resolve()


	


		# reset everything 
		$scope.resetAnswer = (question)->
			
			# cancels out all the answers
			$scope.areAllQuestionAnswered = false
			
			makeTargetChecker('')
			
			#cancels out everything
			$scope.showResult = false

			$scope.card.alreadyAnswered = false
			

			# send the information to the upper scopes
			$scope.$emit('resetAnswer',question)
			

		$scope.$on "showGraph", (result)->
			
			$scope.showResult = true
			
		# when users answer to a main question,
		# check if the user already answered to all its filter questions
		$scope.$on 'answerSubmitted',(message)->



			checkFilterQuestionStatus('')
			
			$timeout ()->
			
				skipThroughFilterQuestions()
				

			,300,true
		
		
		
		# ------------------ Invoke the scope ------------------ #		
		
		$scope.$apply()

