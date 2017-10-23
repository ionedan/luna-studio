{TextEditor, TextBuffer} = require 'atom'
{TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'event-kit'
path = require 'path'
SubAtom = require 'sub-atom'
Spinner = require './spinner'
projects = require './projects'

TextBuffer::setModified = (@modified) ->

TextBuffer::isModified = ->
    if @modified?
        return @modified
    if @file # This is implementation for version 1.18
        return false unless @loaded

        if @file.existsSync()
            return @getText() isnt @cachedDiskContents
    not @isEmpty()

TextBuffer::isInConflict = ->
    if @modified?
        return false
    @isModified() and @fileHasChangedSinceLastLoad

TextBuffer::subscribeToFileOverride = (codeEditor) ->
    @fileSubscriptions?.dispose()
    @fileSubscriptions = new CompositeDisposable

    @fileSubscriptions.add @file.onDidChange =>
        @setModified(false)
        # @conflict = true if @isModified()
        codeEditor.pushInternalEvent(tag: "FileChanged", _path: @getPath())
      #   previousContents = @cachedDiskContents
      #
      #   # Synchrounously update the disk contents because the {File} has already cached them. If the
      #   # contents updated asynchrounously multiple `conlict` events could trigger for the same disk
      #   # contents.
      #   @updateCachedDiskContentsSync()
      #   return if previousContents == @cachedDiskContents
      #
      #   if @conflict
      #     @emitter.emit 'did-conflict'
      #   else
      #     @reload()

    @fileSubscriptions.add @file.onDidDelete ->
        modified = @getText() != @cachedDiskContents
        @wasModifiedBeforeRemove = modified
        @emitter.emit 'did-delete'
        if modified
            @updateCachedDiskContents()
        else
            @destroy()

    @fileSubscriptions.add @file.onDidRename ->
        @emitter.emit 'did-change-path', @getPath()

    @fileSubscriptions.add @file.onWillThrowWatchError (errorObject) ->
        @emitter.emit 'will-throw-watch-error', errorObject

subscribe = null

module.exports =
    class LunaCodeEditorTab extends TextEditor

        constructor: (@uri, @codeEditor) ->
            super
            @setModified(false)
            @setUri(@uri)
            @diffToOmit = new Set()
            @setPlaceholderText 'Please wait'
            @codeEditor.pushInternalEvent(tag: 'OpenFile', _path: @uri)

            @codeEditor.onSetBuffer @setBuffer
            @codeEditor.onSetClipboard @setClipboard
            @codeEditor.onInsertCode @insertCode
            @handleEvents()

            @subscribe = new SubAtom
            @subscribe.add @getBuffer().onDidStopChanging (event) =>
                for change in event.changes
                    if @diffToOmit.has(change.newText)
                        @diffToOmit.delete(change.newText)
                    else
                        @setModified(true)
                        diff =
                            start: change.oldRange.start
                            end:   change.oldRange.end
                            text:  change.newText
                            cursor: @.getCursorBufferPosition()
                          #   cursor: (@getBuffer().characterIndexForPosition(x) for x in @.getCursorBufferPositions()) #for multiple cursors
                        @codeEditor.pushDiff(diff)
            spinner = new Spinner(progress = 0, overlap = true)
            @spinnerElement = @element.appendChild(spinner.element)

        serialize: -> { deserializer: 'LunaCodeEditorTab', uri: @uri }

        getTitle: -> path.basename(@uri)

        isLunaEditor: -> true

        setUri: (uri) =>
            @getBuffer().setPath(uri)
            @getBuffer().subscribeToFileOverride(@codeEditor)
            @uri = uri
        deactivate: -> @subscribe.dispose()

        handleEvents: =>
            atom.commands.add @element,
                'core:copy':  (e) => @handleCopy(e)
                'core:cut':   (e) => @handleCut(e)
                'core:paste': (e) => @handlePaste(e)
                'core:save':  (e) => @handleSave(e)

        spans: =>
            buffer = @getBuffer()
            for s in @getSelections()
                head = s.marker.oldHeadBufferPosition
                tail = s.marker.oldTailBufferPosition
                if head.isEqual tail
                    head.column = 0
                    tail.column = 0
                    tail.row += 1
                [buffer.characterIndexForPosition(head),
                 buffer.characterIndexForPosition(tail)].sort((a,b) -> a - b)

        handleCopy: (e) =>
            e.preventDefault()
            e.stopImmediatePropagation()
            @codeEditor.pushInternalEvent(tag: "Copy", _path: @uri, _selections: @spans())

        handleCut: (e) =>
            @codeEditor.pushInternalEvent(tag: "Copy", _path: @uri, _selections: @spans())

        handlePaste: (e) =>
            cbd = atom.clipboard.readWithMetadata()
            cbdData = []
            if cbd.metadata? && cbd.metadata.selections?
                for x in cbd.metadata.selections
                    cbdData.push(x.text)
            else
                cbdData[0] = cbd.text
            e.preventDefault()
            e.stopImmediatePropagation()
            @codeEditor.pushInternalEvent(tag: "Paste", _selections: @spans(), _content: cbdData)

        handleSave: (e) =>
            @setModified(false)
            e.preventDefault()
            e.stopImmediatePropagation()
            @codeEditor.pushInternalEvent(tag: "SaveFile", _path: @uri)
            oldPath = atom.project.getPaths()[0]
            projects.temporaryProject.save (newPath) =>
                @codeEditor.pushInternalEvent(tag: 'MoveProject', _oldPath : oldPath, _newPath: newPath)

        insertCode: (uri, start, end, text, cursor) =>
            if @uri == uri
                @omitDiff(text)
                @getBuffer().setText(text)

        setClipboard: (uri, text) =>
            if @uri == uri
                atom.clipboard.write(text)

        setBuffer: (uri, text) =>
            if @uri == uri
                if @getPlaceholderText() != ''
                    @setPlaceholderText ''
                for child in @element.childNodes
                    if child.id == 'luna_logo-spinner'
                        @element.removeChild child
                        break
                @omitDiff(text)
                @getBuffer().setText(text)
                console.log "setBuffer"

        setModified: (modified) =>
            @getBuffer().setModified(modified)
            @getBuffer().emitter.emit 'did-change-modified', modified

        omitDiff: (text) =>
            @diffToOmit.add(text)
