'use strict';

describe('Directive: stickyFooter', function () {

  // load the directive's module
  beforeEach(module('pbportalApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<div sticky-footer></div>');
    element = $compile(element)(scope);
    //expect(element.text()).toBe('this is the stickyFooter directive');
  }));
});
