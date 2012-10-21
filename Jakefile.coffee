PATH = require 'path'
FS   = require 'fs'
JAKE = jake

VENDOR_PATH         = PATH.resolve __dirname, 'vendor'
VENDOR_EMBER        = PATH.resolve VENDOR_PATH, 'ember'
VENDOR_EMBER_DATA   = PATH.resolve VENDOR_PATH, 'ember-data'
NEEDS_REAL_WINDOW   = ['metamorph']
NEEDS_GLOBAL_WINDOW = ['metal', 'debug', 'data']
CONVOY_VERSION      = '~0.3'

# Some of the packages in ember don't fully specify their dependencies. Add
# missing dependencies here.
FORCED_DEPENDENCIES = 
  'ember': ['ember-application']
  'states': ['ember-runtime']
  'data': ['ember-states']
  'runtime': ['rsvp']


npmVersion = (version) ->
  matches = (/^([^\d]*\d+\.\d+)(\.\d+)?(\.(.*))?$/).exec version
  if matches
    rep = "#{matches[1]}#{matches[2] or '.0'}"
    rep = "#{rep}-#{matches[4]}" if matches[4]
  else
    rep = version
  rep


desc "builds ember files and package.json for this package from source"
task 'dist', ['vendor:update', 'vendor:dist'], ->
  console.log 'Generating NPM package...'
  packageRoot = __dirname
  externalDependencies = {}
  dependencySources   = {}
  basePackageJSON     = null

  moduleRoot  = PATH.resolve VENDOR_EMBER, 'dist', 'modules'
  moduleNames = FS.readdirSync(moduleRoot).map (filename) ->
    return null if filename == 'handlebars.js' # uses external version
    PATH.basename filename, '.js'
  moduleNames.push 'ember-data' # manually add this.

  moduleNames.forEach (moduleName) ->
    return if !moduleName

    # get paths to origina files before we drop the ember- prefix
    if moduleName == 'ember-data'
      sourcePath = PATH.resolve VENDOR_EMBER_DATA, 'dist', 'modules', "#{moduleName}.js"
      packageJSON = PATH.resolve VENDOR_EMBER_DATA,'packages',moduleName,'package.json'
    else
      sourcePath = PATH.resolve moduleRoot, "#{moduleName}.js"
      packageJSON = PATH.resolve VENDOR_EMBER,'packages',moduleName,'package.json'

    packageJSON = JSON.parse FS.readFileSync(packageJSON, 'utf8')
    basePackageJSON = packageJSON if moduleName == 'ember' # needed later


    moduleName = moduleName.replace /^ember-/, '' 
    console.log "  writing #{moduleName}"

    ## prep dependencies
    dependencies = packageJSON.dependencies || {}
    (FORCED_DEPENDENCIES[moduleName] || []).forEach (packageName) ->
      dependencies[packageName] ||= 'latest'

    ## prep asset body
    outputBody = [
      '//',
      '// This file is automatically generated. any changes will be lost',
      '//',
      ''
    ]
    
    toMerge = []
    
    if NEEDS_REAL_WINDOW.indexOf(moduleName)>=0 or dependencies.jquery
      outputBody.push 'require("window");'
      # TODO: convert to published package
      externalDependencies.window = 
        'git://github.com/charlesjolley/node-window.git#master'

    for packageName, packageVersion of dependencies
      continue if packageName == 'spade' # not needed for node-land
      if moduleNames.indexOf(packageName) >= 0
        outputBody.push "require(\"./#{packageName.replace /^ember-/, ''}\");"
      else
        outputBody.push switch packageName
          when 'handlebars'
            toMerge.push 'Handlebars'
            'var Handlebars = require("handlebars");'
          when 'jquery'
            toMerge.push 'jQuery'
            'var jQuery, $; jQuery = $ = require("jquery");'
          else
            "require(\"#{packageName}\");"

        packageVersion = npmVersion packageVersion
        unless externalDependencies[packageName] == packageVersion
          if externalDependencies[packageName]
            fail """
              ERROR: Multiple versions detected for external dependency
              "#{packageName}". (#{packageVersion} required by #{moduleName}
              vs #{externalDependencies[packageName]} required by 
              #{dependencySources[packageName]}.
              """
          externalDependencies[packageName] = packageVersion
          dependencySources[packageName] = moduleName # for debug info only

    toMerge.forEach (namespace) ->
      outputBody.push "Ember.imports.#{namespace} = Ember.imports.#{namespace} || #{namespace};"

    outputBody.push "\n"

    sourceBody = FS.readFileSync sourcePath, 'utf8'
    if NEEDS_GLOBAL_WINDOW.indexOf(moduleName)>=0
      outputBody.push '(function(window) {'
      outputBody.push sourceBody
      outputBody.push '})("undefined" === typeof global ? window : global);'
    else
      outputBody.push sourceBody

    outputBody = outputBody.join "\n"

    # write out generated file
    outputPath = PATH.resolve __dirname, "#{moduleName}.js"
    FS.writeFileSync outputPath, outputBody


  # package.json
  console.log "  generating package.json"
  packageJSON = {}
  throw new Error("ember package.json not found") unless basePackageJSON
  'name summary description homepage author'.split(' ').forEach (key) ->
    packageJSON[key] = basePackageJSON[key]

  packageJSON.version = "v#{npmVersion basePackageJSON.version}"

  externalDependencies.convoy = CONVOY_VERSION
  packageJSON.dependencies = externalDependencies
  packageJSON.main = './ember.js'
  packageJSON.repository =
    type: 'git'
    url:  'git://github.com/charlesjolley/node-ember.git'

  FS.writeFileSync PATH.resolve(__dirname, 'package.json'),
    JSON.stringify packageJSON, null, 2

  console.log 'Done.'


namespace 'vendor', ->

  desc "Configures the vendor directory. Call first time before build"
  task 'setup', (->
    console.log 'preparing vendor for building'
    jake.exec [
      "git submodule update --init"
      "bundle install --gemfile #{PATH.resolve VENDOR_EMBER, 'Gemfile'}"
      "bundle install --gemfile #{PATH.resolve VENDOR_EMBER_DATA, 'Gemfile'}"
    ], (() -> console.log 'Done.'; complete() ), { stdout: true, stderr: true }
  ), async: true

  desc "Updates vendor directory to latest version"
  task 'update', (->
    console.log 'updating to latest ember'
    jake.exec ['git submodule update'], (() ->
      console.log 'Done.'
      complete()
    ), stdout: true
  ), async: true

  desc "Builds ember files inside of vendor. Invoked before main dist"
  task 'dist', (->
    console.log 'Build distribution in vendor...'
    jake.exec [
      "cd #{VENDOR_EMBER}; rake dist --trace"
      "cd #{VENDOR_EMBER_DATA}; rake dist --trace"
    ], complete, { stdout: true, stderr: true }
  ), async: true
