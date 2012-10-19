eco = require 'eco'
layout = require './layout.eco'

PageResult = require 'lib/results/framework/PageResult'

docs =
	ApiKeyResult:        require './ApiKeyDocumentation'
	MeResult:            require './MeDocumentation'
	RoleResult:          require './RoleDocumentation'
	RoleMemberResult:    require './RoleMemberDocumentation'
	PhaseResult:         require './PhaseDocumentation'
	ProjectResult:       require './ProjectDocumentation'
	ProjectMemberResult: require './ProjectMemberDocumentation'
	WorkspaceResult:  require './WorkspaceDocumentation'
	UserResult:          require './UserDocumentation'

exports.render = (result) ->
	klass = docs[result.constructor.name]
	if not klass? then return undefined
	doc = new klass(result)
	doc.render()
	return layout doc
