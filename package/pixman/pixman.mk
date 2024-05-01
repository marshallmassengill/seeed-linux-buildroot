################################################################################
#
# pixman
#
################################################################################

PIXMAN_VERSION = 0.42.2
PIXMAN_SOURCE = pixman-$(PIXMAN_VERSION).tar.xz
PIXMAN_SITE = https://xorg.freedesktop.org/releases/individual/lib
PIXMAN_LICENSE = MIT
PIXMAN_LICENSE_FILES = COPYING
PIXMAN_CPE_ID_VENDOR = pixman

PIXMAN_INSTALL_STAGING = YES
PIXMAN_DEPENDENCIES = host-pkgconf
HOST_PIXMAN_DEPENDENCIES = host-pkgconf

# For 0001-Disable-tests.patch
PIXMAN_AUTORECONF = YES

# don't build gtk based demos
PIXMAN_CONF_OPTS = \
	--disable-gtk \
	--disable-loongson-mmi \
	--disable-arm-iwmmxt

# Affects only tests, and we don't build tests (see
# 0001-Disable-tests.patch). See
# https://gitlab.freedesktop.org/pixman/pixman/-/issues/76, which says
# "not sure why NVD keeps assigning CVEs like this. This is just a
# test executable".
PIXMAN_IGNORE_CVES += CVE-2023-37769

# The ARM SIMD code from pixman requires a recent enough ARM core, but
# there is a runtime CPU check that makes sure it doesn't get used if
# the HW doesn't support it. The only case where the ARM SIMD code
# cannot be *built* at all is when the platform doesn't support ARM
# instructions at all, so we have to disable that explicitly.
ifeq ($(BR2_ARM_CPU_HAS_ARM),y)
PIXMAN_CONF_OPTS += --enable-arm-simd
else
PIXMAN_CONF_OPTS += --disable-arm-simd
endif

ifeq ($(BR2_ARM_CPU_HAS_ARM)$(BR2_ARM_CPU_HAS_NEON),yy)
PIXMAN_CONF_OPTS += --enable-arm-neon
else
PIXMAN_CONF_OPTS += --disable-arm-neon
endif

PIXMAN_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_101737),y)
PIXMAN_CFLAGS += -O0
endif

PIXMAN_CONF_OPTS += CFLAGS="$(PIXMAN_CFLAGS)"

$(eval $(autotools-package))
$(eval $(host-autotools-package))
