THEOS_DEVICE_IP = 192.168.1.123
FOR_RELEASE=1
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCAlarmETA12

CCAlarmETA12_FILES = Tweak.x
CCAlarmETA12_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
