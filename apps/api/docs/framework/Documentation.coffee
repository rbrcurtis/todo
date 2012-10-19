Result = require 'lib/results/framework/Result'

INDENT = 2

class Documentation
	
	constructor: (@result) ->
		@properties = []
	
	render: ->
		@body = ''
		_.last(@properties).last = true
		@_renderSymbol 'open'
		@_renderProperty property for property in @properties
		@_renderSymbol 'close'
	
	property: (op) ->
		@properties.push _.defaults op, {depth: 1}
	
	link: (template) ->
		(value, breadcrumbs) ->
			resolve = (context, path) ->
				context = context[segment] for segment in path.split '.'
				return context
			url = template
			url = url.replace ':value', value
			url = url.replace /:this\.([^\/]+)/, (match, path) ->
				# The object which owns the property being formatted is the last item in breadcrumbs
				return resolve breadcrumbs[breadcrumbs.length - 1], path
			url = url.replace /:parent\.([^\/]+)/, (match, path) ->
				# The conceptual parent object is the penultimate item in breadcrumbs
				return resolve breadcrumbs[breadcrumbs.length - 2], path
			"<a class='fk' href='#{url}'>#{value}</a>"
	
	_renderProperty: (op) ->
		breadcrumbs = [@result]
		value = @result[op.name]
		
		# Skip properties that don't actually exist in the document.
		return if value is undefined
		
		if value is null then formatted = 'null'
		else if value is NaN then formatted = 'NaN'
		else
			if _.isArray(value)
				value = value.slice(0)
			else if _.isObject(value) and not _.isDate(value)
				value = _.clone(value)
			
			if op.formatter?
				value = @_format value, [], op.formatter, breadcrumbs
				
			if op.formatters?
				for path, formatter of op.formatters
					value = @_format value, path.split('.'), formatter, breadcrumbs
					
			formatted = JSON.stringify(value, false, INDENT)
			formatted = formatted.replace /\n/g, '\n' + @_indent(op.depth)
		
		@body += """
		<tr class='property'>
			<td class='desc'>#{op.desc}</td>
			<td class='type'>#{op.type}</td>
			<td class='data'>
				<pre>#{@_indent(op.depth)}<span class='key'>"#{op.name}"</span>: <span class='value'>#{formatted}</span>#{@_comma(op.last)}</pre>
			</td>
		</tr>
		"""
	
	_renderSymbol: (side) ->
		if @kind is 'array'
			symbol = if side is 'open' then '[' else ']'
		else
			symbol = if side is 'open' then '{' else '}'
		
		@body += """
		<tr class='#{side}'>
			<td class='desc'></td>
			<td class='type'></td>
			<td class='data'>
				<pre>#{symbol}</pre>
			</td>
		</tr>
		"""

	_format: (context, path, formatter, breadcrumbs) ->
		# If we've found the value we need to format, format it and return. (base case)
		if path.length is 0
			if _.isArray context
				return (formatter(item, breadcrumbs) for item in context)
			else
				return formatter(context, breadcrumbs)
			
		# Otherwise, recurse or iterate, depending on the type of the context.
		if _.isArray context
			# If the current context is an array, iterate over its contents.
			for item, index in context
				crumbs = breadcrumbs.concat [item]
				context[index] = @_format item, path, formatter, crumbs
		else if _.isObject(context)
			# If the current context is an object, recurse downwards.
			[segment, remainder...] = path
			context[segment] = @_format context[segment], remainder, formatter, breadcrumbs
		else
			# If we're at a scalar value but we still have segments left, the path is invalid.
			throw new Error("Invalid formatter path")
			
		return context

	_indent: (depth) -> Array(depth * INDENT + 1).join ' '
	_comma:  (last)  -> if last then '' else ','

module.exports = Documentation
