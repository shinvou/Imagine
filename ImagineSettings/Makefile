ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = ImagineSettings
ImagineSettings_FILES = ImagineSettings.mm
ImagineSettings_INSTALL_PATH = /Library/PreferenceBundles
ImagineSettings_FRAMEWORKS = UIKit
ImagineSettings_PRIVATE_FRAMEWORKS = Preferences
ImagineSettings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ImagineSettings.plist$(ECHO_END)
