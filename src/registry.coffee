fs = require "fs"
util = require "util"

# -- constants

_DEFAULT_NAMESPACE_SEPARATOR = ':'

# --

registry = {

	namespaces : {}
	cache : {}

	register : (namespace, path, includeDirs=false) ->

		if(util.isArray(path))
			paths = path
		else
			paths = [path]

		if(namespace.indexOf(_DEFAULT_NAMESPACE_SEPARATOR)>-1)
			throw new Error("Namespace name cannot contain the namespace separator!")

		if(@namespaces[namespace]?)
			throw new Error("Namespace #{ namespace } already exists!")

		try

			for path in paths

				realPath = fs.realpathSync(path)
				if(realPath!=path)
					throw new Error("Namespace path cannot be relative!")

		catch e

			throw e
		
		# define basic structure
		@namespaces[namespace] =
			modules : {}
		@cache[namespace] = {}

		modules = {}

		# scan for modules
		for path in paths

			contents = fs.readdirSync(path)

			for filePath in contents

				stats = fs.statSync(path + '/' + filePath)
				moduleName = filePath.split('.')[0]

				if(includeDirs or !stats.isDirectory())

					if(modules[moduleName]?)
						throw new Error("Namespace #{ namespace } has two colliding modules name #{ filePath }!")

					modules[moduleName] =
						path : path + '/' + moduleName

		@namespaces[namespace].modules = modules

	load : (name) ->

		tokens = name.split(_DEFAULT_NAMESPACE_SEPARATOR)
		moduleName = tokens.pop()
		namespaceName = tokens.join(_DEFAULT_NAMESPACE_SEPARATOR)

		# get namespace
		if(!@namespaces[namespaceName]?)
			throw new Error("Error loading module from registry: Namespace #{ namespaceName } does not exist!")
		namespace = @namespaces[namespaceName]

		# check if namespace has this module
		if(!namespace.modules[moduleName]?)
			throw new Error("Error loading module from registry: Namespace #{ namespaceName } does not have module #{ moduleName }!")

		# cache the module if it's not in cache already
		if(!@cache[namespaceName][moduleName]?)
			@cache[namespaceName][moduleName] = require namespace.modules[moduleName].path

		# return the reference
		return @cache[namespaceName][moduleName]

}

module.exports = registry