import chronos, chronos/threadsync
import os

type
  Context = object
    thread: Thread[(ptr Context)]
    signal: ThreadSignalPtr

proc runWaku(ctx: ptr Context) {.async.} =
  while true:
    try:
      echo "::::::: Waiting for Signal"
      # discard ctx.signal.waitSync() # This works
      await ctx.signal.wait() # This does not
      echo "::::::: SUCCESS"
    except:
        echo "::::::: Error!"

proc run(ctx: ptr Context) {.thread.} =
  waitFor runWaku(ctx)

proc main() {.async.} =
  let ctx = createShared(Context)
  ctx.signal = ThreadSignalPtr.new().expect("free file descriptor for signal")
  
  createThread(ctx.thread, run, ctx)

  echo "::::::: Sending signal"
  let x = ctx.signal.fireSync().expect("SHOULD HAVE FIRED!!!")
  echo "::::::: Signal sent: ", x

  sleep(5000)

waitFor main()