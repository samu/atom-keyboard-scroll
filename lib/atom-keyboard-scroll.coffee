{Point, CompositeDisposable} = require "atom"

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add "atom-text-editor:not(.mini)",
      "atom-keyboard-scroll:scrollUpWithCursor": (e) => @scrollUp(true)

    @subscriptions.add atom.commands.add "atom-text-editor:not(.mini)",
      "atom-keyboard-scroll:scrollDownWithCursor": (e) => @move(e)

    @subscriptions.add atom.commands.add "atom-text-editor:not(.mini)",
      "atom-keyboard-scroll:scrollUp": (e) => @move(e)

    @subscriptions.add atom.commands.add "atom-text-editor:not(.mini)",
      "atom-keyboard-scroll:scrollDown": (e) => @move(e)

  deactivate: ->
    @subscriptions.dispose()

  scrollUp: (moveCursor) ->
    atom.workspace.getActiveEditor().moveCursorUp(1) if moveCursor
    view = atom.workspaceView.getActiveView()
    view.scrollTop(view.scrollTop() - view.lineHeight);

  scrollDown: (moveCursor) ->
    atom.workspace.getActiveEditor().moveCursorDown(1) if moveCursor
    view = atom.workspaceView.getActiveView()
    view.scrollTop(view.scrollTop() + view.lineHeight);
