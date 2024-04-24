SHELL := bash # the shell used internally by "make"

# used inside the included makefiles
BUILD_SYSTEM_DIR := vendor/nimbus-build-system
EXCLUDED_NIM_PACKAGES := vendor/nim-dnsdisc/vendor
LINK_PCRE := 0
LOG_LEVEL := TRACE

# we don't want an error here, so we can handle things later, in the ".DEFAULT" target
-include $(BUILD_SYSTEM_DIR)/makefiles/variables.mk

.PHONY: \
	all \
	deps \
	update \
	main \
	clean

ifeq ($(NIM_PARAMS),)
# "variables.mk" was not included, so we update the submodules.
GIT_SUBMODULE_UPDATE := git submodule update --init --recursive
.DEFAULT:
	+@ echo -e "Git submodules not found. Running '$(GIT_SUBMODULE_UPDATE)'.\n"; \
		$(GIT_SUBMODULE_UPDATE) && \
		echo
# Now that the included *.mk files appeared, and are newer than this file, Make will restart itself:
# https://www.gnu.org/software/make/manual/make.html#Remaking-Makefiles
#
# After restarting, it will execute its original goal, so we don't have to start a child Make here
# with "$(MAKE) $(MAKECMDGOALS)". Isn't hidden control flow great?

else # "variables.mk" was included. Business as usual until the end of this file.

# default target, because it's the first one that doesn't start with '.'
all: | main

# must be included after the default target
-include $(BUILD_SYSTEM_DIR)/makefiles/targets.mk

# add a default Nim compiler argument
NIM_PARAMS += --threads:on

deps: | deps-common
	# Have custom deps? Add them above.

update: | update-common
	# Do you need to do something extra for this target?

# building Nim programs
main: | build deps
	echo -e $(BUILD_MSG) "build/$@" && \
		$(ENV_SCRIPT) "$(NIMC)" c -o:build/$@ $(NIM_PARAMS) main.nim

ANDROID_TARGET ?= 30
ANDROID_TOOLCHAIN_DIR ?= $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64
LINK_PCRE := 0

mobile: ANDROID_ARCH=x86_64-linux-android
mobile: CPU=amd64
mobile: ABIDIR=x86_64
mobile: | build deps
		 ANDROID_ARCH=$(ANDROID_ARCH) CROSS_TARGET=$(ANDROID_ARCH) CPU=$(CPU) ABIDIR=$(ABIDIR) ANDROID_TOOLCHAIN_DIR=$(ANDROID_TOOLCHAIN_DIR) ANDROID_COMPILER=$(ANDROID_ARCH)$(ANDROID_TARGET)-clang $(ENV_SCRIPT) "$(NIMC)" c -o:build/android$@ $(NIM_PARAMS) --passL:-llog --opt:size --cpu:$(CPU) --os:android -d:androidNDK main.nim  

clean: | clean-common
	rm -rf build/*

endif # "variables.mk" was not included

