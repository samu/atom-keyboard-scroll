KeyboardScrollView = require "./keyboard-scroll-view"

module.exports =
  config:
    linesToScrollSingle:
      type: "number"
      default: 3
      title: "Number of lines to scroll for a single hit"

    linesToScrollKeydown:
      type: "number"
      default: 2
      title: "Number of lines to scroll for key down"

    animate:
      type: "boolean"
      default: true
      title: "Animate scroll"

    animationDuration:
      type: "number"
      default: 150
      title: "Duration of animation in milliseconds"

    throttle:
      type: "number"
      default: 20
      title: "Throttling of key down scrolling in milliseconds. This is useful if you have a fast keyrepeat and want to slow down scrolling."

  subscriptions: null

  activate: ->
    atom.workspace.observeTextEditors (editor) ->
      new KeyboardScrollView(editor)
