(function() {
  var fs, registry, util, _DEFAULT_NAMESPACE_SEPARATOR;

  fs = require("fs");

  util = require("util");

  _DEFAULT_NAMESPACE_SEPARATOR = ':';

  registry = {
    namespaces: {},
    cache: {},
    register: function(namespace, path, includeDirs) {
      var contents, e, filePath, moduleName, modules, paths, realPath, stats, _i, _j, _k, _len, _len1, _len2;
      if (includeDirs == null) {
        includeDirs = false;
      }
      if (util.isArray(path)) {
        paths = path;
      } else {
        paths = [path];
      }
      if (namespace.indexOf(_DEFAULT_NAMESPACE_SEPARATOR) > -1) {
        throw new Error("Namespace name cannot contain the namespace separator!");
      }
      if ((this.namespaces[namespace] != null)) {
        throw new Error("Namespace " + namespace + " already exists!");
      }
      try {
        for (_i = 0, _len = paths.length; _i < _len; _i++) {
          path = paths[_i];
          realPath = fs.realpathSync(path);
          if (realPath !== path) {
            throw new Error("Namespace path cannot be relative!");
          }
        }
      } catch (_error) {
        e = _error;
        throw e;
      }
      this.namespaces[namespace] = {
        modules: {}
      };
      this.cache[namespace] = {};
      modules = {};
      for (_j = 0, _len1 = paths.length; _j < _len1; _j++) {
        path = paths[_j];
        contents = fs.readdirSync(path);
        for (_k = 0, _len2 = contents.length; _k < _len2; _k++) {
          filePath = contents[_k];
          stats = fs.statSync(path + '/' + filePath);
          moduleName = filePath.split('.')[0];
          if (includeDirs || !stats.isDirectory()) {
            if ((modules[moduleName] != null)) {
              throw new Error("Namespace " + namespace + " has two colliding modules name " + filePath + "!");
            }
            modules[moduleName] = {
              path: path + '/' + moduleName
            };
          }
        }
      }
      return this.namespaces[namespace].modules = modules;
    },
    load: function(name) {
      var moduleName, namespace, namespaceName, tokens;
      tokens = name.split(_DEFAULT_NAMESPACE_SEPARATOR);
      moduleName = tokens.pop();
      namespaceName = tokens.join(_DEFAULT_NAMESPACE_SEPARATOR);
      if (this.namespaces[namespaceName] == null) {
        throw new Error("Error loading module from registry: Namespace " + namespaceName + " does not exist!");
      }
      namespace = this.namespaces[namespaceName];
      if (namespace.modules[moduleName] == null) {
        throw new Error("Error loading module from registry: Namespace " + namespaceName + " does not have module " + moduleName + "!");
      }
      if (this.cache[namespaceName][moduleName] == null) {
        this.cache[namespaceName][moduleName] = require(namespace.modules[moduleName].path);
      }
      return this.cache[namespaceName][moduleName];
    }
  };

  module.exports = registry;

}).call(this);
