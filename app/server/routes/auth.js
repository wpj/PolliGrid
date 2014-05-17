(function() {
  var User, auth_utility, escapeChar, verification;

  User = require("../models/user");

  auth_utility = require("../lib/auth-utility");

  escapeChar = function(regex) {
    return regex.replace(/([()[{*+.$^\\|?])/g, '\\$1');
  };

  verification = require("../lib/verification");

  module.exports = function(app, passport) {
    app.post("/api/auth/login", passport.authenticate("local-login"), function(req, res, next) {
      if (req.user) {
        return res.send(req.user);
      } else {
        return res.send(req.session.message);
      }
    });
    app.post("/api/auth/signup", passport.authenticate("local-signup"), function(req, res, next) {
      if (req.user) {
        return res.send(req.user);
      } else {
        return res.send(req.session.message);
      }
    });
    app.get("/api/user/:id/:email/:task/:pass", function(req, res) {
      var email, id, isCorrect, pass, task;
      console.log(id = escapeChar(unescape(req.params.id)));
      console.log(email = unescape(req.params.email));
      console.log(task = unescape(req.params.task));
      console.log(pass = unescape(req.params.pass));
      console.log('test');
      isCorrect = false;
      if (task === "findById") {
        return User.findById(id, function(err, user) {
          if (err) {
            return res.send("foundUser", {
              foundUser: false
            });
          } else if (user) {
            return res.send("foundUser", {
              foundUser: true
            });
          } else {
            return res.send("foundUser", {
              foundUser: false
            });
          }
        });
      } else if (task === "findByEmail") {
        return User.find({
          "local.email": email
        }, function(err, user) {
          if (err) {
            return res.send(err);
          } else {
            console.log(user);
            return res.send(user);
          }
        });
      } else if (task === "checkPass") {
        return User.findOne({
          "local.email": email
        }, function(err, user) {
          var validPass;
          if (err) {
            return res.send(isCorrect);
          } else if (user) {
            validPass = user.validPassword(pass);
            if (validPass) {
              isCorrect = true;
            }
            console.log(isCorrect);
            return res.send(isCorrect);
          } else {
            return res.send(isCorrect);
          }
        });
      }
    });
    app.post('/api/resetPass/:email/:pass', function(req, res) {
      var email, pass;
      console.log(email = unescape(req.params.email));
      console.log(pass = unescape(req.params.pass));
      User.findOne({
        "local.email": email
      }, function(err, user) {
        var newPassword, newUser;
        if (err) {
          return res.send(err);
        } else if (user) {
          newUser = new User();
          newPassword = newUser.generateHash(pass);
          user.local.password = newPassword;
          return user.save(function(err, user) {
            if (err) {
              throw err;
            } else {
              return res.send(user);
            }
          });
        }
      });
      return app.post("/upload", function(req, res) {
        fs.readFile(req.files.localPhoto.path, function(err, data) {
          var newPath;
          if (err) {
            res.send(403);
          } else {
            if (req.files.localPhoto.type !== "image/png" && req.files.localPhoto.type !== "image/jpeg" && req.files.localPhoto.type !== "image/gif") {
              res.send(403);
            } else {
              newPath = __dirname + "/../public/images/" + req.user.profile.username + ".jpg";
              fs.writeFile(newPath, data, function(err) {
                if (err) {
                  throw err;
                } else {
                  req.user.profile.photos.local = req.protocol + "://" + req.get("host") + "/images/" + req.user.profile.username + ".jpg";
                  req.user.save();
                  res.redirect("back");
                }
              });
            }
          }
        });
      });
    });
    app.get("/api/checkPass", function(req, res, next) {
      var isCorrect;
      isCorrect = false;
      return User.findOne({
        "local.email": req.body.email
      }, function(err, user) {});
    });
    return app.get("/verify/:token", function(req, res, next) {
      var token;
      token = req.params.token;
      verification.verifyUser(token, "verify", function(err, user) {
        if (err) {
          res.redirect("/#/verification/fail");
        } else if (!user) {
          res.redirect("/#/verification/fail");
        } else {
          res.redirect("/#/verification/success");
        }
      });
    });
  };

}).call(this);
