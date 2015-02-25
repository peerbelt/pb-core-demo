'use strict';

describe('Controller: DomainModalCtrl', function () {

  // load the controller's module
  beforeEach(module('pbportalApp'));

  var DomainModalCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    DomainModalCtrl = $controller('DomainModalCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    //expect(scope.awesomeThings.length).toBe(3);
  });
});
