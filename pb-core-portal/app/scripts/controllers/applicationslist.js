'use strict';

/**
 * @ngdoc function
 * @name pbportalApp.controller:ApplicationslistCtrl
 * @description
 * # ApplicationslistCtrl
 * Controller of the pbportalApp
 */
angular.module('pbportalApp')
  .controller('ApplicationslistCtrl', function ($scope, $state, applicationListModel) {
    var stateChangeSuccessListener;

    applicationListModel.getAllApplications($state.params.userId)
      .then(function (data) {
        $scope.applications = data.array;
        $scope.applicationsSelect = angular.copy(data.array);
        $scope.applicationsSelect.unshift({id: 'all-pb-applications', name: 'All'});
        if ($state.params.userId && $state.params.appId) {
          $scope.showMultipleApplications = false;
          $scope.showSingleApplication = true;
        } else {
          $scope.showMultipleApplications = true;
          $scope.showSingleApplication = false;
          $scope.selectedCurrentApplication = $scope.applicationsSelect[0];
        }
      });

    stateChangeSuccessListener = $scope.$on('$stateChangeSuccess', function (event, toState, toParams, fromState, fromParams) {
      if (toState.name === 'applications') {
        $scope.showMultipleApplications = true;
        $scope.showSingleApplication = false;
      }
      if (toState.name === 'applications.application') {
        $scope.showMultipleApplications = false;
        $scope.showSingleApplication = true;
      }
    });

    $scope.$on('$destroy', function () {
      stateChangeSuccessListener();
    });

    $scope.openAppView = function (appId) {
      if (!appId) {
        appId = $scope.selectedCurrentApplication.id;
      }
      if (appId === 'all-pb-applications') {
        return $state.go('applications');
      }
      $state.go('applications.application', {appId: appId});
      $scope.showMultipleApplications = false;
      $scope.showSingleApplication = true;
    };

    var currentApplicationChangedListener = $scope.$on('currentApplicationChanged', function (event, data) {
      var i;
      $scope.currentApplication = data;
      for (i = 0; i < $scope.applicationsSelect.length; i++) {
        if ($scope.applicationsSelect[i].id === data.id) {
          $scope.selectedCurrentApplication = $scope.applicationsSelect[i];
        }
      }
    });

    $scope.$on('$destroy', currentApplicationChangedListener);

    $scope.openNewAppView = function () {
      $state.go('newApplication', {userId: $state.params.userId});
    };
  });
