ifndef sqlite.mk
sqlite.mk := $(abspath $(lastword $(MAKEFILE_LIST)))

include $(dir $(sqlite.mk))/global/config.mk
include $(dir $(sqlite.mk))/global/helper.mk
include $(dir $(sqlite.mk))/brew.mk

.PHONY: \
	install \
	install.sqlite

install: install.sqlite
install.sqlite: $(brew.path)/Cellar/sqlite .sqlite

.IGNORE \
.PHONY: \
	clean \
	clean.sqlite

clean: clean.sqlite
clean.sqlite:

.IGNORE \
.PHONY: \
	trash \
	trash.sqlite

trash: trash.sqlite
trash.sqlite:
	rm -rf .sqlite
	brew uninstall sqlite3

.PHONY: \
	exec \
	exec.sqlite

exec: exec.sqlite
exec.sqlite:
	sudo $(shell which sqlite) \
		-u $(call ask,sqlite,username,root) \
		$(call ask,sqlite,database,)

.PHONY: \
	backup \
	backup.sqlite

backup: backup.sqlite
backup.sqlite:
	$(MAKE) .sqlite/backup/$(call ask,sqlite,date,$(shell date '+%Y-%m-%d'))/$(call ask,sqlite,database,).sql

.PHONY: \
	restore \
	restore.sqlite

restore: restore.sqlite
restore.sqlite: \
	date = $(call select,sqlite,database,$(shell ls .sqlite/backup)) \
	database = $(call select,sqlite,database,$(shell ls .sqlite/backup/$(sqlite/date)))
restore.sqlite: login.sqlite .sqlite/backup
	sqlite3 db.$(database) < .sqlite/backup/$(date)/$(database).sql

.sqlite:
	mkdir -p $@

.sqlite/backup: .sqlite
	mkdir -p $@

.sqlite/backup/%.sql: .sqlite/backup
	[ -e "$(dir $@)" ] || mkdir $(dir $@)
	sqlite3 db.$(basename $(*F)) .dump > $@

endif # sqlite.mk