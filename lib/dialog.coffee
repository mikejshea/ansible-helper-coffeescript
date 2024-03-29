{TextEditor, CompositeDisposable, Disposable, Emitter, Range, Point} = require 'atom'
path = require 'path'

module.exports =
class Dialog
  constructor: ({newRole, select, iconClass, prompt} = {}) ->
    @emitter = new Emitter()
    @disposables = new CompositeDisposable()

    @element = document.createElement('div')
    @element.classList.add('tree-view-dialog')

    @promptText = document.createElement('label')
    @promptText.classList.add('icon')
    @promptText.classList.add(iconClass) if iconClass
    @promptText.textContent = prompt
    @element.appendChild(@promptText)

    @miniEditor = new TextEditor({mini: true})
    blurHandler = =>
      @close() if document.hasFocus()
    @miniEditor.element.addEventListener('blur', blurHandler)
    @disposables.add(new Disposable(=> @miniEditor.element.removeEventListener('blur', blurHandler)))
    # @disposables.add(@miniEditor.onDidChange => @showError())
    @element.appendChild(@miniEditor.element)

    @errorMessage = document.createElement('div')
    @errorMessage.classList.add('error-message')
    @element.appendChild(@errorMessage)

    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()

    @miniEditor.setText(newRole)

    if select
      # extension = path.extname(newRole)
      # baseName = path.basename(newRole)
      # selectionStart = newRole.length
      # if baseName is extension
      selectionEnd = newRole.length
      # else
      #   selectionEnd = newRole.length - extension.length
      @miniEditor.setSelectedBufferRange(Range(Point(0, 0), Point(0, selectionEnd)))

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this)
    @miniEditor.element.focus()
    @miniEditor.scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    @emitter.dispose()
    @disposables.dispose()
    @miniEditor.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()
    document.querySelector('.tree-view')?.focus()

  showError: (message='') ->
    @errorMessage.textContent = message
    if message
      @element.classList.add('error')
      window.setTimeout((=> @element.classList.remove('error')), 300)
