'use strict';

/**
 * @ngdoc service
 * @name pbportalApp.resources
 * @description
 * # resources
 * Service in the pbportalApp.
 */
angular.module('pbportalApp')
  .service('resources', function ($resource) {
    var baseUrl = 'data/';
    return {
      getUserApplications: function (userId) {
        var resource = $resource(baseUrl + 'data.json', {}, {get: {method: 'GET', isArray: true}});
        return resource.get().$promise;
      }
    };
  });
