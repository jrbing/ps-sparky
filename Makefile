#===============================================================================
# vim: softtabstop=4 shiftwidth=4 noexpandtab fenc=utf-8 spelllang=en nolist
#===============================================================================

SPARKY_HOME=~/.ps-sparky
ETC_FILES := $(shell cd $(SPARKY_HOME)/etc; ls)

all: link

link:
	@cd ~ && for file in $(ETC_FILES); do ln -nfs .ps-sparky/etc/$$file .$$file; done

check-dead:
	@find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -print

clean-dead:
	@find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -delete

.PHONY: link check-dead clean-dead
