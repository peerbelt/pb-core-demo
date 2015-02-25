'use strict';

module.exports = function (grunt) {

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Cleans dist folder
  grunt.initConfig({
    clean: {
      dist: {
        files: [{
          src: 'dist/'
        }]
      }
    },

    // Copies all files
    copy: {
      dist: {
        files: [{
				 	expand: true,
				 	cwd: 'app/',
          src: ['**/*'],
          dest: 'dist/'
        }]
      }
    }
  });

  grunt.registerTask('dist', [
    'clean:dist',
    'copy:dist'
  ]);

  grunt.registerTask('default', [
    'dist'
  ]);
};
