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

  animate2: ->

  animateLineScroll: (isKeydown, lines, @doneCallback) ->
    if isKeydown
      unless @animationIsRunning
        to = @editor.getScreenLineCount() * @editor.getLineHeightInPixels()
        # to = @editor.getScrollTop() - @editor.getLineHeightInPixels() * lines
        difference = to - @editor.getScrollTop()
        duration = difference
        @animation = jQuery({top: @editor.getScrollTop()}).animate({top: to}, duration: duration, easing: "linear", step: @step, done: @done)
        @animationIsRunning = yes
      clearTimeout(@timeout)
      @timeout = setTimeout((=>
          @animation.stop()
          @animationIsRunning = no
        ), 100)
    else
      to = @editor.getScrollTop() - @editor.getLineHeightInPixels() * lines
      duration = 120
      if atom.config.get('atom-keyboard-scroll.animate')
        duration = atom.config.get('atom-keyboard-scroll.animationDuration')
      jQuery({top: @editor.getScrollTop()}).animate({top: to}, duration: duration, easing: "linear", step: @step, done: @done)

  oldanimateLineScroll: (isKeydown, lines, @doneCallback) ->
    # @editor.getScreenLineCount() * @editor.getLineHeightInPixels()
    # console.log "HERE"
    if @animationIsRunning
      # console.log "running"
    else
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
        @scrollUp(e.originalEvent.repeat, true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDownWithCursor": (e) =>
        @scrollDown(e.originalEvent.repeat, true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUp": (e) =>
        @scrollUp(e.originalEvent.repeat, false)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDown": (e) =>
        # console.log e.originalEvent.repeat
        # console.log e.originalEvent.type
        @scrollDown(e.originalEvent.repeat, false)

  deactivate: ->
    @subscriptions.dispose()

  scrollUp: (isKeydown, moveCursor) ->
    linesToScroll = atom.config.get('atom-keyboard-scroll.linesToScroll')
    editor = atom.workspace.getActiveTextEditor()
    scrollAnimation.setEditor(editor)
    scrollAnimation.animateLineScroll(isKeydown, linesToScroll, ->
      editor.moveUp(linesToScroll) if moveCursor
    )

  scrollDown: (isKeydown, moveCursor) ->
    linesToScroll = atom.config.get('atom-keyboard-scroll.linesToScroll')
    editor = atom.workspace.getActiveTextEditor()
    scrollAnimation.setEditor(editor)
    scrollAnimation.animateLineScroll(isKeydown, -linesToScroll, ->
      editor.moveDown(linesToScroll) if moveCursor
    )
