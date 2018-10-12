include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = strawpref
strawpref_FILES = StrawRootListController.m
strawpref_INSTALL_PATH = /Library/PreferenceBundles
strawpref_FRAMEWORKS = UIKit
strawpref_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
strawpref_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/strawpref.plist$(ECHO_END)
