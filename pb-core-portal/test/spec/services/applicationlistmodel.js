'use strict';

describe('Service: applicationlistmodel', function () {

  // load the service's module
  beforeEach(module('pbportalApp'));

  // instantiate service
  var applicationListModel;
  beforeEach(inject(function (_appLicationlistModel_) {
    applicationListModel = _appLicationlistModel_;
  }));

  it('should do something', function () {
    expect(!!applicationListModel).toBe(true);
  });

});
