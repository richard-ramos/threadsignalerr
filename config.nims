--threads:on
--opt:speed
--excessiveStackTrace:on
# enable metric collection
--define:metrics
# for heap-usage-by-instance-type metrics and object base-type strings
--define:nimTypeNames

switch("define", "withoutPCRE")

# `switch("warning[CaseTransition]", "off")` fails with "Error: invalid command line option: '--warning[CaseTransition]'"
switch("warning", "CaseTransition:off")

# The compiler doth protest too much, methinks, about all these cases where it can't
# do its (N)RVO pass: https://github.com/nim-lang/RFCs/issues/230
switch("warning", "ObservableStores:off")

# Too many false positives for "Warning: method has lock level <unknown>, but another method has 0 [LockLevel]"
switch("warning", "LockLevel:off")

if defined(android):
  var clang = getEnv("ANDROID_COMPILER")
  var ndk_home = getEnv("ANDROID_TOOLCHAIN_DIR")
  var sysroot = ndk_home & "/sysroot"
  var cincludes = sysroot & "/usr/include/" & getEnv("ANDROID_ARCH")
  switch("clang.path", ndk_home & "/bin")
  switch("clang.exe", clang)
  switch("clang.linkerexe", clang)
  switch("passC", "--sysroot=" & sysRoot)
  switch("passL", "--sysroot=" & sysRoot)
  switch("cincludes", sysRoot & "/usr/include/")
