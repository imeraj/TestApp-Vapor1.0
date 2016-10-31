'use strict';

var gulp = require('gulp');
var vapor = require('gulp-vapor');

vapor.config.commands.build = 'vapor build';

gulp.task('vapor:start', vapor.start);
gulp.task('vapor:reload', vapor.reload);

gulp.task ( 'watch', function () {
     var target = [
         './Sources/**/*'
     ];
     gulp.watch (target, ['vapor:reload']);
});

gulp.task('default', ['vapor:start', 'watch']);
