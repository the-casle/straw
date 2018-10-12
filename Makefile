include $(THEOS)/makefiles/common.mk

TWEAK_NAME = straw

straw_FILES = Tweak.xm TCMediaNotificationController.mm
straw_PRIVATE_FRAMEWORKS = MediaPlayer MediaRemote


straw_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += strawpref
include $(THEOS_MAKE_PATH)/aggregate.mk
