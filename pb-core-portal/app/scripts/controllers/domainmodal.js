'use strict';

/**
 * @ngdoc function
 * @name pbportalApp.controller:DomainmodalCtrl
 * @description
 * # DomainmodalCtrl
 * Controller of the pbportalApp
 */
angular.module('pbportalApp')
  .controller('DomainModalCtrl', function ($scope) {
    $scope.ok = function () {
      console.log('closing');
      //$modalInstance.close();
    };

    $scope.cancel = function () {
      console.log('closing');
      //$modalInstance.dismiss();
    };
  });
