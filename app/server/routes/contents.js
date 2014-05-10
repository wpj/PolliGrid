(function() {
  var Filter, Question, escapeChar;

  Question = require('../models/question');

  Filter = require('../models/targetQuestion');

  escapeChar = function(regex) {
    return regex.replace(/([()[{*+.$^\\|?])/g, '\\$1');
  };

  exports.makeQuestion = function(req, res) {
    var newQuestion;
    newQuestion = new Question(req.body);
    return newQuestion.save(function(error, newQuestion) {
      if (error) {
        return console.log(error);
      } else {
        return res.send(newQuestion);
      }
    });
  };

  exports.findById = function(req, res) {
    var callback, id;
    callback = function(err, data) {
      if (err) {
        return res.send(err);
      } else {
        return res.json(data);
      }
    };
    id = escapeChar(unescape(req.params.questionId));
    return Question.findById(id).exec(callback);
  };

  exports.findQuestions = function(req, res) {
    var callback, category, offset, order, sorting, term;
    callback = function(err, data) {
      if (err) {
        return res.send(err);
      } else {
        return res.json(data);
      }
    };
    term = escapeChar(unescape(req.params.searchTerm));
    category = escapeChar(unescape(req.params.category));
    order = escapeChar(unescape(req.params.order));
    offset = req.params.offset;
    if (term === "All") {
      term = "";
    }
    if (category === "All") {
      category = "";
    }
    switch (order) {
      case "Recent":
        sorting = {
          "created_at": -1
        };
        break;
      case "Old":
        sorting = {
          "created_at": 1
        };
        break;
      case "Most voted":
        sorting = {
          "totalResponses": -1
        };
        break;
      case "Most popular":
        sorting = {
          "numOfFavorites": -1
        };
    }
    return Question.find({
      $or: [
        {
          "question": new RegExp(term, 'i')
        }, {
          "option": {
            $elemMatch: {
              "title": new RegExp(term, 'i')
            }
          }
        }
      ]
    }).where("category").equals(new RegExp(category, 'i')).sort(sorting).limit(6).skip(offset).exec(callback);
  };

  exports.updateQuestion = function(req, res) {
    var callback, conditions, filterId, index, options, questionId, task, title, updates, userId;
    callback = function(err, updated) {
      if (err) {
        return res.send(err);
      } else {
        console.log(updated);
        return res.send(updated);
      }
    };
    questionId = escapeChar(unescape(req.params.questionId));
    userId = escapeChar(unescape(req.params.userId));
    title = escapeChar(unescape(req.params.title));
    filterId = escapeChar(unescape(req.params.filterId));
    task = escapeChar(unescape(req.params.task));
    index = req.params.index;
    if (task === "remove") {
      console.log('remove answers');
      conditions = {
        "_id": questionId,
        "option.title": title
      };
      updates = {
        $inc: {
          "option.$.count": -1,
          "totalResponses": -1
        },
        $pull: {
          "option.$.answeredBy": userId,
          "respondents": userId
        }
      };
    } else {
      if (filterId !== "0") {
        console.log('update question filter');
        conditions = {
          "_id": questionId,
          "targets._id": filterId
        };
        updates = {
          $push: {}
        };
        updates.$push["targets.$.lists." + index + ".answeredBy"] = userId;
      } else {
        console.log('update question');
        conditions = {
          "_id": questionId,
          "option.title": title
        };
        updates = {
          $inc: {
            "option.$.count": 1,
            "totalResponses": 1
          },
          $push: {
            "option.$.answeredBy": userId,
            "respondents": userId
          }
        };
      }
    }
    options = {
      upsert: true
    };
    return Question.update(conditions, updates, options, callback);
  };

  exports.getQuestionTitle = function(req, res) {
    var callback, category, term;
    callback = function(err, questions) {
      var questionMap;
      questionMap = [];
      questions.forEach(function(question) {
        return questionMap.unshift(question);
      });
      return res.send(questionMap);
    };
    term = escapeChar(unescape(req.params.term));
    category = escapeChar(unescape(req.params.category));
    if (category === "All") {
      category = "";
    }
    return Question.find({
      $or: [
        {
          "question": new RegExp(term, 'i')
        }, {
          "option": {
            $elemMatch: {
              "title": new RegExp(term, 'i')
            }
          }
        }
      ]
    }).where("category").equals(new RegExp(category, 'i')).limit(6).exec(callback);
  };

  exports.loadFilters = function(req, res) {
    var callback, filters, offset, term;
    callback = function(err, filters) {
      var filterMap;
      filterMap = [];
      filters.forEach(function(filter) {
        return filterMap.unshift(filter);
      });
      return res.send(filterMap);
    };
    term = escapeChar(unescape(req.params.searchTerm));
    offset = req.params.offset;
    if (term === "all") {
      term = "";
    }
    return filters = Filter.find({
      $or: [
        {
          "title": new RegExp(term, 'i')
        }, {
          "question": new RegExp(term, 'i')
        }
      ]
    }).limit(6).skip(offset).exec(callback);
  };

  exports.getFilterTitle = function(req, res) {
    var callback, term;
    callback = function(err, filters) {
      var filterMap;
      filterMap = [];
      filters.forEach(function(filter) {
        return filterMap.unshift(filter);
      });
      return res.send(filterMap);
    };
    term = escapeChar(unescape(req.params.term));
    return Filter.find({
      "title": new RegExp(term, 'i')
    }).limit(6).exec(callback);
  };

  exports.makeFilter = function(req, res) {
    var newFilter;
    newFilter = new Filter(req.body);
    return newFilter.save(function(error, filter) {
      if (error) {
        return console.log(error);
      } else {
        return res.send(filter);
      }
    });
  };

}).call(this);
