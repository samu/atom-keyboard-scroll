{Point, CompositeDisposable} = require "atom"
{jQuery} = require 'atom-space-pen-views'

animationRunning = undefined

module.exports =

  subscriptions: null


  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUpWithCursor": (e) =>
        # console.log e.originalEvent.type
        # console.log e.originalEvent
        @scrollUp(true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDownWithCursor": (e) =>
        # console.log e.originalEvent.type
        # console.log e.originalEvent
        @scrollDown(true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUp": (e) => @scrollUp(false)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDown": (e) => @scrollDown(false)

  deactivate: ->
    @subscriptions.dispose()


  animate: (from, to, editor) ->
    step = (currentStep) ->
      editor.setScrollTop(currentStep)

    done = ->
      animationRunning = false

    unless animationRunning
      animationRunning = true
      jQuery({top: from}).animate({top: to}, duration: 100, easing: "swing", step: step, done: done)

  scrollUp: (moveCursor) ->
    editor = atom.workspace.getActiveTextEditor()
    @animate(editor.getScrollTop(), editor.getScrollTop() - editor.getLineHeightInPixels() * 5, editor)
    editor.moveUp(5) if moveCursor
    # editor.setScrollTop(editor.getScrollTop() - editor.getLineHeightInPixels() * 5)

  scrollDown: (moveCursor) ->
    editor = atom.workspace.getActiveTextEditor()
    @animate(editor.getScrollTop(), editor.getScrollTop() + editor.getLineHeightInPixels() * 5, editor)
    editor.moveDown(5) if moveCursor
    # editor.setScrollTop(editor.getScrollTop() + editor.getLineHeightInPixels() * 5)
