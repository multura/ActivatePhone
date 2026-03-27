ARCHS = arm64 arm64e arm
TARGET = iPhone:clang:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ActivatePhone

ActivatePhone_FILES = Tweak.x
ActivatePhone_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
