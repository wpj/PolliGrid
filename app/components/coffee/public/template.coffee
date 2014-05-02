define ['angular'], (angular) ->
	angular.module('myapp.template', [])
			
			.run ($templateCache)->
				$templateCache.put "question.html",'
					<li ng-hide="targetQ.isQuestionAnswered" class=\'answer\'>
						<label class=\'pointer\'>
							<input ng-model="answer" type="radio" name="answer" ng-value="#OBJ#">
								{{#OBJ#.title}}
						</label>
					</li>'
				
			.run ($templateCache)->
				$templateCache.put "targetQuestion-options.html",'
					<li class="answer">
						<label class="pointer">
							<input ng-model="$targetAnswer" type="radio" name="targetAnswer" ng-value="#OBJ#">
							{{#OBJ#.option}}
						</label>
					</li>'


			.run ($templateCache)->
				$templateCache.put "targetQuestion.html","
					<div  class=\"content animated fadeInLeft\" >
						<p class='question'>
							{{#OBJ#.question}}
						</p>
						
						<!-- Warning message -->
						<p ng-show=\"warning\" class=\"animated fadeIn alert alert-danger\">
							Please select something
						</p>
						
						<form ng-submit=\"submitTarget(card,targetAnswer,$index)\">
							
							<ul no-scope-repeat-for-targets-options items=\"#OBJ#.lists\" class=\"answers\"></ul>

							<input type=\"submit\" class=\"submit-button btn btn-primary btn-sm\" value=\"Next\">
						</form>
					</div>

					<div class=\"content animated fadeInLeft\" ng-show=\"areAllQuestionAnswered\">	
						<h4 class=\"gray result-label\">
							Result:
						</h4>

						<p class=\"question gray\">
							{{card.question}}
						</p>

						<hr>

						<ul class=\"answers\">
							<li class=\"blue\">	
								Total count: 
								<span class=\"badge\">
									{{card.totalResponses}}
								</span>
							
							</li>
							<li class=\"answer gray\" ng-repeat=\"option in question.options\">
								{{option.title}}: 
								<span>
									{{option.count}}
								</span>
							</li>
						</ul>
					 	
						<div class=\"canvas-wrapper\">
							<canvas  ng-if=\"areAllQuestionAnswered\" piechart options=\"myChartOptions\" class=\"chart-main\" data=\"myChartData\" width=\"320\" height=\"320\"></canvas>
						</div>

					    
						<button ng-hide=\"isAccessedViaLink\" ng-click=\"resetAnswer(card)\" class=\"reset-button bigger btn btn-default\">
							Reset
						</button>

						<!-- This will show up on the setting page -->
						<!-- ui-sref=\"home.anotherDeep({id:card.id})\" -->
						<button ng-if=\"isAccessedFromSetting\"  ng-click=\"showDeepResult(card.id)\" class=\"submit-button bigger btn btn-success\">
							See deep result
						</button>
						

						<!-- If the question is accessed via an external link, show this button. This won't refresh the page -->
						<button ng-if=\"isAccessedViaLink && !isAccessedFromSetting && !user.isLoggedIn\" ng-click=\"closeQuestionModal()\" ui-sref=\"home.signupRedirect({id:card.id})\" class=\"submit-button bigger btn btn-success\">
							See deep result
						</button>

						<!-- when users is not logged in -  -->
						<button ng-if=\"isAccessedViaLink && !isAccessedFromSetting && user.isLoggedIn\" ng-click=\"closeQuestionModal()\" ui-sref=\"home.deepResult({id:card.id})\" class=\"submit-button bigger btn btn-success\">
							See deep result
						</button>

						<!-- This will refresh the page -->
						<button ng-if=\"!isAccessedViaLink && !isAccessedFromSetting\" ui-sref=\"home.deepResult({id:card.id})\" class=\"submit-button bigger btn btn-success\">
							See deep result
						</button>
					</div>"

				
			


		