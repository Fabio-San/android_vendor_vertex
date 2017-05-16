# VertexOS Version
PRODUCT_VERSION = v3.1
CODE_NAME = Carbide

# Unofficial by default unless defined
ifndef VERTEX_BUILDTYPE
	VERTEX_BUILDTYPE := UNOFFICIAL
endif

# Version Shown in Settings -> About
ifeq ($(VERTEX_BUILDTYPE),OFFICIAL)
VERTEX_MODVERSION := $(CODE_NAME)-$(PRODUCT_VERSION)
else
VERTEX_MODVERSION := $(CODE_NAME)-$(PRODUCT_VERSION)-$(VERTEX_BUILDTYPE)-$(shell date -u +%Y%m%d)
endif

# Name of flashable zip
VERTEX_VERSION := VertexOS-$(CODE_NAME)-$(PRODUCT_VERSION)-$(VERTEX_BUILDTYPE)-$(shell date -u +%Y%m%d)-$(VERTEX_BUILD)

PRODUCT_PROPERTY_OVERRIDES += \
  ro.vertex.version=$(VERTEX_VERSION) \
  ro.vertex.releasetype=$(VERTEX_BUILDTYPE) \
  ro.modversion=$(VERTEX_MODVERSION)

PRODUCT_PROPERTY_OVERRIDES += \
  ro.vertex.display.version=$(VERTEX_VERSION) \

# Boot Animation
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/bootanimation/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.opa.eligible_device=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Enable Tethering
PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.dun.override=0

# Import some sounds
$(call inherit-product-if-exists, frameworks/base/data/sounds/GoogleAudio.mk)

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Iapetus.ogg \
    ro.config.alarm_alert=Timer.ogg

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication for user and userdebug
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Recommend using the non debug dexpreopter
USE_DEX2OAT_DEBUG := false

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/vertex/CHANGELOG.mkdn:system/etc/CHANGELOG-VertexOS.txt

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/vertex/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/vertex/prebuilt/common/bin/50-vertex.sh:system/addon.d/50-vertex.sh \
    vendor/vertex/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/vertex/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/vertex/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# Local init file
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/etc/init.local.rc:root/init.local.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/vertex/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

## Dev Tools
#ifneq ($(TARGET_BUILD_VARIANT),user)
#PRODUCT_PACKAGES += \
#    Development
#endif

# Optional Vertex packages
PRODUCT_PACKAGES += \
    libemoji \
    WallpaperPicker \
    LiveWallpapersPicker \

# Include explicitly to work around GMS issues
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full \
    librsjni

# Custom Vertex packages
PRODUCT_PACKAGES += \
    ExactCalculator \
    Launcher3 \
    LockClock \
    ThemeInterfacer	

# Bluetooth Audio (A2DP)
PRODUCT_PACKAGES += libbthost_if

# Exchange support
PRODUCT_PACKAGES += \
    Exchange2

# Support additional filesystems
PRODUCT_PACKAGES += \
    fsck.ntfs \
    mke2fs \
    mkfs.ntfs \
    mount.ntfs \
    tune2fs

# ExFAT support
WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Extra tools in Vertex
PRODUCT_PACKAGES += \
    bzip2 \
    curl \
    gdbserver \
    libsepol \
    micro_bench \
    sqlite3 \
    strace \
    wget

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

## Custom off-mode charger
#ifneq ($(WITH_CM_CHARGER),false)
#PRODUCT_PACKAGES += \
#    charger_res_images \
#    cm_charger_res_images \
#    font_log.png \
#    libhealthd.cm
#endif

# Stagefright FFMPEG plugin
ifneq ($(BOARD_USES_QCOM_HARDWARE),true)
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so
endif

# Storage manager
PRODUCT_PROPERTY_OVERRIDES += \
    ro.storage_manager.enabled=true

# Telephony
PRODUCT_PACKAGES += \
    telephony-ext \

PRODUCT_BOOT_JARS += \
    telephony-ext

DEVICE_PACKAGE_OVERLAYS += vendor/vertex/overlay/common

# Signing Builds
ifeq ($(OTA_PACKAGE_SIGNING_KEY),)
    PRODUCT_EXTRA_RECOVERY_KEYS += \
        vendor/vertex/build/target/product/security/vertex \
        vendor/vertex/build/target/product/security/vertex-devkey
endif

-include vendor/vertex-priv/keys/keys.mk
