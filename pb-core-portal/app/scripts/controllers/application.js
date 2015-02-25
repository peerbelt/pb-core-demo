'use strict';

/**
 * @ngdoc function
 * @name pbportalApp.controller:ApplicationCtrl
 * @description
 * # ApplicationCtrl
 * Controller of the pbportalApp
 */
angular.module('pbportalApp')
  .controller('ApplicationCtrl', function ($scope, applicationListModel, $state, $timeout) {
    if (!$state.params.appId) {
      $scope.currentApplication = applicationListModel.createBlankAppRecord();
    } else {
      applicationListModel.createAppRecordFromTemplate({id: $state.params.appId})
        .then(function (data) {
          $scope.currentApplication = data;
          $scope.$emit('currentApplicationChanged', data);
        });
    }
    $scope.addAnEmptyDomain = function () {
      applicationListModel.addDefaultDomainToApplication($scope.currentApplication);
      $timeout(function () {
        $('.panel-title').trigger('click');
      }, 200);
    };
  });
