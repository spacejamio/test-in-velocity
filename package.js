Package.describe({
  name: "spacejamio:test-in-velocity",
  summary: "A meteor test-packages driver package to run package tests and report the results to velocity.",
  git: "https://github.com/spacejamio/test-in-velocity.git",
  version: '0.1.0'
});

Package.onUse(function (api) {
  // XXX this should go away, and there should be a clean interface
  // that tinytest and the driver both implement?
  api.use('coffeescript');
  api.use('tinytest');
  api.use('underscore');
  //api.use('session');
  //api.use('reload');

  api.use(['blaze', 'templating', 'spacebars', 'ddp', 'tracker'], 'client');

  api.use(['spacejamio:loglevel', 'spacejamio:chai']);

  api.add_files([
    'client/runner.html',
    'client/TinytestResult.coffee',
    'client/Velocity.coffee',
    'client/TestRunner.coffee',
    'client/runner.template.coffee'
  ], "client");

  api.use('autoupdate', 'server');
  api.use('random', 'server');
  api.add_files('server/autoupdate.js', 'server');
  api.add_files('server/getVelocityUrl.coffee', 'server');

  api.export('TinytestResult', 'client');
});
