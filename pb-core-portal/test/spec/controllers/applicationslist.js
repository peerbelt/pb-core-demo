'use strict';

describe('Controller: ApplicationslistCtrl', function () {

  // load the controller's module
  beforeEach(module('pbportalApp'));

  var ApplicationslistCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    ApplicationslistCtrl = $controller('ApplicationslistCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    //expect(scope.awesomeThings.length).toBe(3);
  });
});
