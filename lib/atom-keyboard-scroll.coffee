{Point, CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUpWithCursor": (e) => @scrollUp(true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDownWithCursor": (e) => @scrollDown(true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollUp": (e) => @scrollUp(false)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "atom-keyboard-scroll:scrollDown": (e) => @scrollDown(false)

  deactivate: ->
    @subscriptions.dispose()

  scrollUp: (moveCursor) ->
    atom.workspace.getActiveEditor().moveCursorUp(1) if moveCursor
    view = atom.workspaceView.getActiveView()
    view.scrollTop(view.scrollTop() - view.lineHeight)

  scrollDown: (moveCursor) ->
    atom.workspace.getActiveEditor().moveCursorDown(1) if moveCursor
    view = atom.workspaceView.getActiveView()
    view.scrollTop(view.scrollTop() + view.lineHeight)
