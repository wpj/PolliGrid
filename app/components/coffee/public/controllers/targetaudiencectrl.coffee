define ['underscore'], (_)->
	($scope,Question)->

		
		getColor = ()->
			'#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6)

		# ------------------ Scope variables ------------------ #
		
		$scope.num = 0
		$scope.showResult = false
		$scope.targetAnswer = ""

		$scope.myChartData = [
	        	value: 30,
	        	color: "#F38630",
	        	label: 'Yo yo yo yo yo',
	        	labelColor: 'black',
	        	labelFontSize: '12'
    		,
        		value: 50,
        		color: "#E0E4CC"
        		label: 'HELLO super \nagative omg ',
	        	labelColor: 'black',
	        	labelFontSize: '12'
    		, 
        		value: 100,
        		color: "#69D2E7"
        		label: 'HELLO',
	        	labelColor: 'black',
	        	labelFontSize: '12'
    	]	




		# ------------------ Scope funcitons ------------------ #
		
		$scope.submitTarget = (question,targetAnswer)->


			# warning message pops up if users didn't choose any answer
			if targetAnswer is "" or !targetAnswer
			
				$scope.warning = true

			else

				# remove the warniing popup since the user selected something
				$scope.warning = false

				# this will get the id of the target audience question.
				targetQuestionID = question.targets[$scope.num].id

				# user's answer to the target question
				answer = 
					id 		: targetQuestionID
					answer 	:targetAnswer
				
				

				# $scope num will increment everytime users answer to
				# target audience question.
				# when the $scope num matches the total number of the filter questions
				# then the result seciton will be shown.
				if $scope.num == question.numOfFilters-1
					
					# since the question.numOfFilters is one more
					# than $scope.num so by euqalizing them, 
					# the target audience section will be hidden
					$scope.num = question.numOfFilters

					# add the answer to the user's list
					$scope.user.filterQuestionsAnswered.push(answer)

					# this will show the result section
					$scope.showResult = true


					# for i in question.options
					# 	num = question.options[i].count
					# 	color = getColor()
					# 	newValue = 
					# 		value : num
					# 		color : color
					# 	$scope.myChartData.push(newValue)


				else

					$scope.num++

					# add the answer to the user's list
					$scope.user.filterQuestionsAnswered.push(answer)					



		# reset everything 
		$scope.resetAnswer = (question)->
			
			# remove filterQuestionAnswered one by one
			# $scope.num = 0 means no new answers
			$scope.num = 0

			#cancels out everything
			$scope.showResult = false
			

			# send the information to the upper scopes
			$scope.$emit('resetAnswer',question)
			
			
			


		
		
		# ------------------ Invoke the scope ------------------ #		
		
		$scope.$apply()


