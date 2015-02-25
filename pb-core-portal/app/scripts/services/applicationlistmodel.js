/* jshint camelcase: false */
'use strict';

/**
 * @ngdoc service
 * @name pbportalApp.applicationlistmodel
 * @description
 * # applicationlistmodel
 * Service in the pbportalApp.
 */
angular.module('pbportalApp')
  .service('applicationListModel', function ($q, resources) {
    var allApplicationsArray;
    var allApplicationsHash;
    var getAllApplicationPromise = function () {
      var allApplicationsDfd = $q.defer();
      if (!allApplicationsHash && !allApplicationsArray) {
        resources.getUserApplications()
          .then(function (data) {
            allApplicationsHash = createIdMappedHashFromArray(data);
            allApplicationsArray = data;
            allApplicationsDfd.resolve({
              hash: allApplicationsHash,
              array: allApplicationsArray
            });
          });
      } else {
        allApplicationsDfd.resolve({
          hash: allApplicationsHash,
          array: allApplicationsArray
        });
      }
      return allApplicationsDfd.promise;
    };
    var getApplicationByIdOrIndex = function (idObject) {
      if (idObject.index) {
        return allApplicationsArray[idObject.index];
      }
      if (idObject.id) {
        return allApplicationsHash[idObject.id];
      }
    };
    var createIdMappedHashFromArray = function (applicationArray) {
      var i;
      allApplicationsArray = applicationArray;
      allApplicationsHash = {};
      for (i = 0; i < applicationArray.length; i++) {
        allApplicationsHash[applicationArray[i].id] = applicationArray[i];
      }
      return allApplicationsHash;
    };
    var DefaultDomainObject = function () {
      return {
        glob: 'Your new PeerBelt domain',
        selectors: {
          article: '.pb_post',
          title: '.pb_title',
          main_image: '.pb_main_image',
          thumbnail: '.pb_thumbnail',
          exclude: '.pb_exclude'
        },
        use_crawl: false,
        url_normalizer: ''
      };
    };
    var BlankApplication = function () {
      var domains = [];
      domains.push(new DefaultDomainObject());
      return {
        name: '',
        description: '',
        keys: '',
        pb_rest_endpoint: '',
        domains: domains
      };
    };
    return {
      getAllApplications: function () {
        return getAllApplicationPromise();
      },
      getApplication: function (idObject) {
        var applicationDfd = $q.defer();
        getAllApplicationPromise()
          .then(function () {
            applicationDfd.resolve(getApplicationByIdOrIndex(idObject));
          });
        return applicationDfd.promise;
      },
      updateApplication: function (idObject, updatedPorperties) {
        return angular.extend(getApplicationByIdOrIndex(idObject), updatedPorperties);
      },
      createBlankAppRecord: function () {
        return new BlankApplication();
      },
      createAppRecordFromTemplate: function (idObject) {
        var applicationDfd = $q.defer();
        getAllApplicationPromise()
          .then(function () {
            applicationDfd.resolve(angular.copy(getApplicationByIdOrIndex(idObject)));
          });
        return applicationDfd.promise;
      },
      addDefaultDomainToApplication: function (application) {
        application.domains.unshift(new DefaultDomainObject());
        return application;
      }
    };
  });
