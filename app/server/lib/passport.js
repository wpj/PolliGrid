(function() {
  var FacebookStrategy, GoogleStrategy, LocalStrategy, TwitterStrategy, User, configAuth, uniqify_name, verification;

  LocalStrategy = require("passport-local").Strategy;

  FacebookStrategy = require("passport-facebook").Strategy;

  TwitterStrategy = require("passport-twitter").Strategy;

  GoogleStrategy = require("passport-google-oauth").OAuth2Strategy;

  User = require("../models/user");

  configAuth = require("../config/oauth");

  verification = require("./verification");

  uniqify_name = function(name, num, callback) {
    return User.findOne({
      "name": name
    }, function(err, user) {
      var stringNum;
      if (err) {
        throw err;
      } else if (user) {
        stringNum = num.toString();
        name = name.concat(stringNum);
        num++;
        return uniqify_name(name, num, callback);
      } else {
        return callback(name);
      }
    });
  };

  module.exports = function(passport) {
    passport.serializeUser(function(user, done) {
      return done(null, user.id);
    });
    passport.deserializeUser(function(id, done) {
      return User.findById(id, function(err, user) {
        return done(err, user);
      });
    });
    passport.use("local-login", new LocalStrategy({
      usernameField: "email",
      passwordField: "password",
      passReqToCallback: true
    }, function(req, email, password, done) {
      return process.nextTick(function() {
        return User.findOne({
          "local.email": email
        }, function(err, user) {
          if (err) {
            return done(err);
          } else if (!user) {
            req.session.message = "No user found";
            return done(null, false, req.session.message);
          } else if (!user.validPassword(password)) {
            req.session.message = "Wrong password";
            return done(null, false, req.session.message);
          } else {
            user.visitorId.unshift(req.body.visitorId);
            return user.save(function(err, readyUser) {
              if (err) {
                throw err;
              } else {
                return done(null, user);
              }
            });
          }
        });
      });
    }));
    passport.use("local-signup", new LocalStrategy({
      usernameField: "email",
      passwordField: "password",
      passReqToCallback: true
    }, function(req, email, password, done) {
      req.session.message = "";
      return process.nextTick(function() {
        return User.findOne({
          "local.email": email
        }, function(err, user) {
          var callback, name, nameMatch;
          if (err) {
            return done(err);
          } else if (user) {
            req.session.message = "That Email is already taken";
            return done(null, false, req.session.message);
          } else {
            nameMatch = email.match(/^([^@]*)@/);
            name = (nameMatch ? nameMatch[1] : null);
            if (name) {
              callback = function(name) {
                var newUser;
                newUser = new User();
                newUser.username = name;
                newUser.email = email;
                newUser.visitorId.push(req.body.visitorId);
                newUser.profilePic = "/img/users/default_img.png";
                newUser.local.email = email;
                newUser.local.password = newUser.generateHash(password);
                newUser.confirmed = false;
                newUser.hasEmail = true;
                return newUser.save(function(err, user) {
                  if (err) {
                    return done(err);
                  } else {
                    verification.sendVerification(req, newUser, email);
                    return done(null, newUser);
                  }
                });
              };
              return uniqify_name(name, 1, callback);
            } else {
              return done(null);
            }
          }
        });
      });
    }));
    passport.use("facebook", new FacebookStrategy({
      clientID: configAuth.facebookAuth.clientID,
      clientSecret: configAuth.facebookAuth.clientSecret,
      callbackURL: configAuth.facebookAuth.callbackURL,
      passReqToCallback: true
    }, function(req, token, refreshToken, profile, done) {
      return process.nextTick(function() {
        var picUrl, userId;
        userId = profile.id;
        picUrl = "https://graph.facebook.com/" + userId + "/picture";
        return User.findOne({
          "facebook.id": profile.id
        }, function(err, user) {
          var newUser;
          if (err) {
            return done(err);
          } else if (user) {
            return done(null, user);
          } else {
            newUser = new User();
            newUser.facebook.id = profile.id;
            newUser.facebook.token = token;
            newUser.username = profile.name.givenName + " " + profile.name.familyName;
            newUser.email = profile.emails[0].value;
            newUser.profilePic = picUrl;
            newUser.confirmed = false;
            newUser.hasEmail = true;
            return newUser.save(function(err, user) {
              if (err) {
                return done(err);
              } else {
                verification.sendVerification(req, newUser, newUser.email);
                return done(null, newUser);
              }
            });
          }
        });
      });
    }));
    passport.use("twitter", new TwitterStrategy({
      consumerKey: configAuth.twitterAuth.consumerKey,
      consumerSecret: configAuth.twitterAuth.consumerSecret,
      callbackURL: configAuth.twitterAuth.callbackURL,
      passReqToCallback: true
    }, function(req, token, tokenSecret, profile, done) {
      process.nextTick(function() {});
      return User.findOne({
        "twitter.id": profile.id
      }, function(err, user) {
        var newUser;
        if (err) {
          return done(err);
        } else if (user) {
          return done(null, user);
        } else {
          console.log("twitter user : Nothing was found");
          newUser = new User();
          newUser.twitter.id = profile.id;
          newUser.twitter.token = token;
          newUser.twitter.tokenSecret = tokenSecret;
          newUser.username = profile.displayName.replace(/\s/g, "-");
          newUser.profilePic = profile.photos[0].value;
          newUser.confirmed = false;
          newUser.hasEmail = false;
          return newUser.save(function(err) {
            if (err) {
              return done(err);
            } else {
              return done(null, newUser);
            }
          });
        }
      });
    }));
    return passport.use("google", new GoogleStrategy({
      clientID: configAuth.googleAuth.clientID,
      clientSecret: configAuth.googleAuth.clientSecret,
      callbackURL: configAuth.googleAuth.callbackURL,
      passReqToCallback: true
    }, function(req, token, refreshToken, profile, done) {
      process.nextTick(function() {});
      return User.findOne({
        "google.id": profile.id
      }, function(err, user) {
        var newUser;
        if (err) {
          return done(err);
        } else if (user) {
          return done(null, user);
        } else {
          newUser = new User();
          newUser.google.id = profile.id;
          newUser.google.token = token;
          newUser.username = profile.displayName.replace(/\s/g, "-");
          newUser.email = profile.emails[0].value;
          newUser.profilePic = profile._json.picture;
          newUser.confirmed = false;
          newUser.hasEmail = true;
          return newUser.save(function(err, user) {
            if (err) {
              return done(err);
            } else {
              verification.sendVerification(req, newUser, newUser.email);
              return done(null, newUser);
            }
          });
        }
      });
    }));
  };

}).call(this);
