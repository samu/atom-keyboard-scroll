{Point, CompositeDisposable} = require "atom"
{jQuery} = require 'atom-space-pen-views'

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
    @doneCallback?()

  animate: ->
    to = @scrollTopBeforeStart - @editor.getLineHeightInPixels() * @linesToScroll
    @animation?.stop()
    duration = 0
    if atom.config.get('atom-keyboard-scroll.animate')
      duration = atom.config.get('atom-keyboard-scroll.animationDuration')
    @animation = jQuery({top: @editor.getScrollTop()}).animate({top: to}, duration: duration, easing: "linear", step: @step, done: @done)

  animateLineScroll: (lines, @doneCallback) ->
    unless @animationIsRunning
      @animationIsRunning = yes
      @linesToScroll = lines
      @scrollTopBeforeStart = @editor.getScrollTop()
      @animate()

scrollAnimation = new ScrollAnimation()

module.exports =
  config:
    linesToScroll:
      type: "number"
      default: 4
      title: "Number of lines to scroll"

    animate:
      type: "boolean"
      default: true
      title: "Animate scroll"

    animationDuration:
      type: "number"
      default: 80
      title: "Duration of animation in milliseconds"

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
    linesToScroll = atom.config.get('atom-keyboard-scroll.linesToScroll')
    editor = atom.workspace.getActiveTextEditor()
    scrollAnimation.setEditor(editor)
    scrollAnimation.animateLineScroll(linesToScroll, ->
      editor.moveUp(linesToScroll) if moveCursor
    )

  scrollDown: (moveCursor) ->
    linesToScroll = atom.config.get('atom-keyboard-scroll.linesToScroll')
    editor = atom.workspace.getActiveTextEditor()
    scrollAnimation.setEditor(editor)
    scrollAnimation.animateLineScroll(-linesToScroll, ->
      editor.moveDown(linesToScroll) if moveCursor
    )
