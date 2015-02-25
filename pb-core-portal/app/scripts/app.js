'use strict';

/**
 * @ngdoc overview
 * @name pbportalApp
 * @description
 * # pbportalApp
 *
 * Main module of the application.
 */
angular
  .module('pbportalApp', [
    'ngAnimate',
    'ngResource',
    'ngSanitize',
    'ngTouch',
    'ui.router',
    'ui.bootstrap',
    'ngDialog'
  ])
  .config(function ($urlRouterProvider, $stateProvider) {
    $urlRouterProvider.otherwise('/login');
    $stateProvider
      .state('login', {
        url: '/login',
        templateUrl: 'views/login.html',
        controller: 'LoginCtrl',
        title: 'PeerBelt - Login'
      })
      .state('applications', {
        url: '/users/:userId/applications',
        templateUrl: 'views/applications-list.html',
        controller: 'ApplicationslistCtrl',
        title: 'Applications'
      })
      .state('applications.application', {
        url: '/:appId',
        templateUrl: 'views/application.html',
        controller: 'ApplicationCtrl'
      })
      .state('newApplication', {
        url: '/users/:userId/application/new',
        templateUrl: 'views/application-new.html',
        controller: 'ApplicationCtrl',
        title: 'New PeerBelt Application'
      });
  });
