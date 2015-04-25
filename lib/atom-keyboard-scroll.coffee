{Point, CompositeDisposable} = require "atom"
{jQuery} = require 'atom-space-pen-views'

animationRunning = undefined

class ScrollAnimation
  constructor: ->
    @animationIsRunning = no
    @linesToScroll = 0
    @scrollTopBeforeStart = 0
    @animation = undefined

  setEditor: (@editor) ->

  step: (currentValue) =>
    @editor?.setScrollTop(currentValue)

  done: =>
    @linesToScroll = 0
    @animationIsRunning = no

  animate: ->
    to = @scrollTopBeforeStart - @editor.getLineHeightInPixels() * @linesToScroll
    @animation?.stop()
    @animation = jQuery({top: @editor.getScrollTop()}).animate({top: to}, duration: 80, easing: "linear", step: @step, done: @done)

  animateLineScroll: (lines) ->
    unless @animationIsRunning
      @animationIsRunning = yes
      @linesToScroll = lines
      @scrollTopBeforeStart = @editor.getScrollTop()
      @animate()

scrollAnimation = new ScrollAnimation()

module.exports =

  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUpWithCursor": (e) =>
        @scrollUp(true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDownWithCursor": (e) =>
        @scrollDown(true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUp": (e) => @scrollUp(false)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDown": (e) => @scrollDown(false)

  deactivate: ->
    @subscriptions.dispose()

  scrollUp: (moveCursor) ->
    editor = atom.workspace.getActiveTextEditor()
    scrollAnimation.setEditor(editor)
    scrollAnimation.animateLineScroll(5)
    editor.moveUp(5) if moveCursor

  scrollDown: (moveCursor) ->
    editor = atom.workspace.getActiveTextEditor()
    scrollAnimation.setEditor(editor)
    scrollAnimation.animateLineScroll(-5)
    editor.moveDown(5) if moveCursor
