{Point, CompositeDisposable} = require "atom"
{jQuery} = require 'atom-space-pen-views'
{_} = require 'underscore-plus'

module.exports = class AtomGitDiffDetailsView
  linesToScrollSingle: undefined
  linesToScrollKeydown: undefined
  animationDuration: undefined
  throttledScroll: undefined

  reloadConfig: ->
    @linesToScrollSingle = atom.config.get('keyboard-scroll.linesToScrollSingle')
    @linesToScrollKeydown = atom.config.get('keyboard-scroll.linesToScrollKeydown')

    if atom.config.get('keyboard-scroll.animate')
      @animationDuration = atom.config.get('keyboard-scroll.animationDuration')
    else
      @animationDuration = 1

    @throttledScroll = _.throttle ((fn) => fn()), atom.config.get('keyboard-scroll.throttle')

  constructor: (@editor) ->
    @editorElement = atom.views.getView(@editor)

    @subscriptions = new CompositeDisposable()

    @subscriptions.add @editor.onDidDestroy =>
      @subscriptions.dispose()

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollUpWithCursor", (e) =>
      @throttledScroll(=> @scrollUp(e.originalEvent.repeat, true))

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollDownWithCursor", (e) =>
      @throttledScroll(=> @scrollDown(e.originalEvent.repeat, true))

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollUp", (e) =>
      @throttledScroll(=> @scrollUp(e.originalEvent.repeat, false))

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollDown", (e) =>
      @throttledScroll(=> @scrollDown(e.originalEvent.repeat, false))

    @subscriptions.add atom.config.onDidChange "keyboard-scroll.linesToScrollSingle", =>
      @reloadConfig()

    @subscriptions.add atom.config.onDidChange "keyboard-scroll.linesToScrollKeydown", =>
      @reloadConfig()

    @subscriptions.add atom.config.onDidChange "keyboard-scroll.animate", =>
      @reloadConfig()

    @subscriptions.add atom.config.onDidChange "keyboard-scroll.animationDuration", =>
      @reloadConfig()

    @subscriptions.add atom.config.onDidChange "keyboard-scroll.throttle", =>
      @reloadConfig()

    @reloadConfig()

  step: (editorElement, currentStep) ->
    editorElement.setScrollTop(currentStep)

  animate: (from, to, editorElement) ->
    jQuery({top: from}).animate(
      {top: to}, duration: @animationDuration, easing: "swing",
      step: (currentStep) => @step(editorElement, currentStep),
      done: =>
    )

  doMoveCursor: (moveCursor, direction, linesToScroll) =>
    if moveCursor
      if direction is 1
        @editor.moveDown(linesToScroll)
      else
        @editor.moveUp(linesToScroll)

  doScroll: (isKeydown, moveCursor, direction) ->
    if isKeydown
      @doMoveCursor(moveCursor, direction, @linesToScrollKeydown)
      @editorElement.setScrollTop(@editorElement.getScrollTop() + (@editor.getLineHeightInPixels() * @linesToScrollKeydown * direction))
      @editorElement.component.updateSync()
    else
      @animate(@editorElement.getScrollTop(), @editorElement.getScrollTop() + (@editor.getLineHeightInPixels() * @linesToScrollSingle * direction), @editorElement)
      @doMoveCursor(moveCursor, direction, @linesToScrollSingle)

  scrollUp: (isKeydown, moveCursor) ->
    @doScroll(isKeydown, moveCursor, -1)

  scrollDown: (isKeydown, moveCursor) ->
    @doScroll(isKeydown, moveCursor, 1)
