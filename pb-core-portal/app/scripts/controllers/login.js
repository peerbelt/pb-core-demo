/* jshint unused: false */
'use strict';

/**
 * @ngdoc function
 * @name pbportalApp.controller:LoginCtrl
 * @description
 * # LoginCtrl
 * Controller of the pbportalApp
 */
angular.module('pbportalApp')
  .controller('LoginCtrl', function ($scope, $state, applicationListModel, resources) {
    $scope.userLogin = function () {
      $state.go('applications', {userId: 'some-user-id'});
    };
  });
