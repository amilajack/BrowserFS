# An implementation of the File interface that operates on a file that is
# completely in-memory. PreloadFiles are backed by a Buffer.
#
# This is also an abstract class, as it lacks an implementation of 'sync' and
# 'close'. Each filesystem that wishes to use this file representation must
# extend this class and implement those two methods.
class BrowserFS.File.PreloadFile extends BrowserFS.File
  # Creates a file with the given path and, optionally, the given contents. Note
  # that, if contents is specified, it will be mutated by the file!
  # @param [String] _path
  # @param [BrowserFS.node.fs.Stats] _stat The stats object for the given file.
  #   PreloadFile will *not* mutate this file. Note that this object must
  #   contain the appropriate mode that the file was opened as.
  # @param [BrowserFS.node.Buffer?] contents A buffer containing the entire
  #   contents of the file. If not specified, we assume it is a new file.
  constructor: (@_path, @_stat, contents) ->
    if contents? and contents instanceof BrowserFS.node.Buffer
      @_buffer = contents
    else
      # Empty buffer. It'll expand once we write stuff to it.
      @_buffer = new BrowserFS.node.Buffer 0
    # Note: This invariant is *not* maintained once the file starts getting
    # modified.
    if @_stat.size != @_buffer.byteLength()
      throw new Error 'Invalid buffer: Size differs from size specified in Stats object.'

  # Get the path to this file.
  # @return [String] The path to the file.
  getPath: -> return @_path
  # Get the current file position.
  # @return [Number] The current file position.
  getPos: -> return 0

  # **Core**: Asynchronous sync. Must be implemented by subclasses of this
  # class.
  # @param [Function(BrowserFS.ApiError)] cb
  sync: (cb)-> cb new BrowserFS.ApiError BrowserFS.ApiError.NOT_SUPPORTED
  # **Core**: Asynchronous close. Must be implemented by subclasses of this
  # class.
  # @param [Function(BrowserFS.ApiError)] cb
  close: (cb)-> cb new BrowserFS.ApiError BrowserFS.ApiError.NOT_SUPPORTED


  # Asynchronous `stat`.
  # @param [Function(BrowserFS.ApiError, BrowserFS.node.fs.Stats)] cb
  stat: (cb) -> cb null, @_stat.clone()
  # Asynchronous truncate.
  # @param [Number] len
  # @param [Function(BrowserFS.ApiError)] cb
  truncate: (len, cb)->
    @_stat.size = len
    @_stat.mtime = Date.now()
    cb null
  # Write buffer to the file.
  # Note that it is unsafe to use fs.write multiple times on the same file
  # without waiting for the callback. For this scenario,
  # BrowserFS.node.fs.createWriteStream is strongly recommended.
  # @param [BrowserFS.node.Buffer] buffer Buffer containing the data to write to
  #  the file.
  # @param [Number] offset Offset in the buffer to start reading data from.
  # @param [Number] length The amount of bytes to write to the file.
  # @param [Number] position Offset from the beginning of the file where this
  #   data should be written. If position is null, the data will be written at
  #   the current position.
  # @param [Function(BrowserFS.ApiError, Number, BrowserFS.node.Buffer)]
  #   cb The number specifies the number of bytes written into the file.
  write: (buffer, offset, length, position=@getPos(), cb) ->
    endFp = position+length
    if endFp > @_stat.size
      @_stat.size = endFp
      if endFp > @_buffer.byteLength()
        # Extend the buffer!
        newBuff = new Buffer(endFp)
        @_buffer.copy newBuff
        @_buffer = newBuff

    len = buffer.copy @_buffer, position, offset, offset+length
    @_stat.mtime = Date.now()
    cb null, len, buffer
  # Read data from the file.
  # @param [BrowserFS.node.Buffer] buffer The buffer that the data will be
  #   written to.
  # @param [Number] offset The offset within the buffer where writing will
  #   start.
  # @param [Number] length An integer specifying the number of bytes to read.
  # @param [Number] position An integer specifying where to begin reading from
  #   in the file. If position is null, data will be read from the current file
  #   position.
  # @param [Function(BrowserFS.ApiError, Number, BrowserFS.node.Buffer)] cb The
  #   number is the number of bytes read
  read: (buffer, offset, length, position=@getPos(), cb)->
    rv = @_buffer.copy buffer, offset, position, position+length
    @_stat.atime = Date.now()
    cb null, rv, buffer
