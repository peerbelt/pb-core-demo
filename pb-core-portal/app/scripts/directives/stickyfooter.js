'use strict';

/**
 * @ngdoc directive
 * @name pbportalApp.directive:stickyfooter
 * @description
 * # stickyfooter
 */
angular.module('pbportalApp')
  .directive('stickyFooter', function () {
    return {
      restrict: 'A',
      link: function postLink(scope, element, attrs) {
        var header = element.parent().find('header');
        var footer = element.parent().find('footer');
        var footerOverallVerticalSpace = footer.height() + parseFloat(footer.css('border-top'));
        var overallHeight = $(window).height();
        var minHeight = overallHeight - footerOverallVerticalSpace;
        //console.log(headerHeight,footerHeight, overallHeight,  minHeight);
        element.css('minHeight', minHeight + 'px');
      }
    };
  });
