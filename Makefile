TARGET = iphone:clang:latest:6.0
ARCHS = armv7
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LanguageIconsFix
LanguageIconsFix_FILES = Tweak.xm
LanguageIconsFix_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
