### Compiling
```
export ANDROID_NDK_HOME=/path/to/Android/Sdk/android-ndk-r25b

make update
make mobile
```

### Pushing binary into android emulator
You need to have the android platform tools installed somewhere and the emulator running
```
adb root
adb push ./build/androidmobile /data/androidmobile
```

### Seeing the binary output
This is required to see the `echo` output. You need to have the android platform tools installed somewhere and the emulator running
```
# Execute in a separate terminal window
adb logcat
```

### Executing the program
```
adb shell

# Then in the android emulator terminal
su
chmod 777 /data/androidmobile
/data/androidmobile
```

### The problem:
In `main.nim` if you use `await ctx.signal.wait()`, in logcat you will see the following output:
```
04-24 09:43:46.459  1101  1101 V nim     : ::::::: Sending signal
04-24 09:43:46.459  1101  1101 V nim     : ::::::: Signal sent: true
04-24 09:43:46.460  1101  1102 V nim     : ::::::: Waiting for Signal
```
Notice how the program is stuck waiting for a signal to be received. (It should have printed: `::::::: SUCCESS`)
In the android terminal you'll see this error:
```
/home/richard/waku-org/threadsignal/main.nim(20) run
/home/richard/waku-org/threadsignal/vendor/nim-chronos/chronos/internal/asyncfutures.nim(660) waitFor
/home/richard/waku-org/threadsignal/vendor/nim-chronos/chronos/internal/asyncfutures.nim(635) pollFor
/home/richard/waku-org/threadsignal/vendor/nim-chronos/chronos/internal/asyncengine.nim(1031) poll
/home/richard/waku-org/threadsignal/vendor/nim-chronos/chronos/ioselects/ioselectors_poll.nim(226) selectInto2
/home/richard/waku-org/threadsignal/vendor/nimbus-build-system/vendor/Nim/lib/system/fatal.nim(54) sysFatal
Error: unhandled exception: value out of range: 1 notin 2147483648 .. 2147483647 [RangeDefect]
```

If you change `main.nim` to use `discard ctx.signal.waitSync()` instead, the execution will be succesful, and you'll see the following output in the terminal
```
04-24 09:41:10.172  1080  1080 V nim     : ::::::: Sending signal
04-24 09:41:10.172  1080  1080 V nim     : ::::::: Signal sent: true
04-24 09:41:10.173  1080  1081 V nim     : ::::::: Waiting for Signal
04-24 09:41:10.173  1080  1081 V nim     : ::::::: SUCCESS
04-24 09:41:10.173  1080  1081 V nim     : ::::::: Waiting for Signal
```

