################################################################################
#
# quest-os
#
################################################################################
# SPDX-License-Identifier: GPL-2.0-or-later

QUEST_OS_VERSION = local
QUEST_OS_SITE = $(BR2_EXTERNAL_QRK_APPS_PATH)/quest_os/QuestOS
QUEST_OS_SITE_METHOD = local
QUEST_OS_LICENSE = GPL-2.0, GPL-2.0+, BSD-2-Clause, LGPL-2.1, MIT, BSD-3-Clause, Apache-2.0
QUEST_OS_LICENSE_FILES = LICENSE THIRD_PARTY_NOTICES.md
QUEST_OS_DEPENDENCIES = host-python3 qemu
QUEST_OS_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = \
	--exclude=/build/ --exclude=/include/asm/generated/ \
	--exclude=/thirdparty/tf-a/ --exclude=/third_party/optee_os/

define QUEST_OS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		OUT_DIR=build BUILD_DIR=build \
		CONFIG_PSCI_METHOD=hvc CONFIG_QUEST_OS_AUTOSTART=0 \
		build/quest_os_pack_all.bin
endef

define QUEST_OS_INSTALL_TARGET_CMDS
	# Remove files owned by the earlier affinity workaround from reused targets.
	rm -f $(TARGET_DIR)/usr/libexec/quest_os/pin-exec \
		$(TARGET_DIR)/usr/share/quest_os/licenses/PIN_EXEC_LICENSE.txt
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_QRK_APPS_PATH)/quest_os/quest_os.sh \
		$(TARGET_DIR)/usr/bin/quest_os
	$(INSTALL) -D -m 0644 $(@D)/build/quest_os_pack_all.bin \
		$(TARGET_DIR)/usr/share/quest_os/quest_os.bin
	$(INSTALL) -D -m 0644 $(@D)/LICENSE \
		$(TARGET_DIR)/usr/share/quest_os/licenses/LICENSE
	$(INSTALL) -D -m 0644 $(@D)/THIRD_PARTY_NOTICES.md \
		$(TARGET_DIR)/usr/share/quest_os/licenses/THIRD_PARTY_NOTICES.md
endef

$(eval $(generic-package))
