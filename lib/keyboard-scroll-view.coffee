{Point, CompositeDisposable} = require "atom"
{jQuery} = require 'atom-space-pen-views'
{_} = require 'underscore-plus'

module.exports = class AtomGitDiffDetailsView
  animationDuration: undefined

  constructor: (@editor) ->
    @editorElement = atom.views.getView(@editor)

    if atom.config.get('keyboard-scroll.animate')
      @animationDuration = atom.config.get('keyboard-scroll.animationDuration')

    @subscriptions = new CompositeDisposable()

    @subscriptions.add @editor.onDidDestroy =>
      @subscriptions.dispose()

    throttledScroll = _.throttle ((fn) => fn()), 30

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollUpWithCursor", (e) =>
      throttledScroll(=> @scrollUp(e.originalEvent.repeat, true))

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollDownWithCursor", (e) =>
      throttledScroll(=> @scrollDown(e.originalEvent.repeat, true))

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollUp", (e) =>
      throttledScroll(=> @scrollUp(e.originalEvent.repeat, false))

    @subscriptions.add atom.commands.add @editorElement, "keyboard-scroll:scrollDown", (e) =>
      throttledScroll(=> @scrollDown(e.originalEvent.repeat, false))

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
      linesToScroll = atom.config.get('keyboard-scroll.linesToScrollKeydown')
      @doMoveCursor(moveCursor, direction, linesToScroll)
      @editorElement.setScrollTop(@editorElement.getScrollTop() + (@editor.getLineHeightInPixels() * linesToScroll * direction))
      @editorElement.component.updateSync()
    else
      linesToScroll = atom.config.get('keyboard-scroll.linesToScrollSingle')
      @animate(@editorElement.getScrollTop(), @editorElement.getScrollTop() + (@editor.getLineHeightInPixels() * linesToScroll * direction), @editorElement)
      @doMoveCursor(moveCursor, direction, linesToScroll)

  scrollUp: (isKeydown, moveCursor) ->
    @doScroll(isKeydown, moveCursor, -1)

  scrollDown: (isKeydown, moveCursor) ->
    @doScroll(isKeydown, moveCursor, 1)
