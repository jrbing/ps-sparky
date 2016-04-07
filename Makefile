#===============================================================================
# vim: softtabstop=4 shiftwidth=4 noexpandtab fenc=utf-8 spelllang=en nolist
#===============================================================================

config_files = bash_profile bashrc profile vimrc

all: link

link:
	@cd ~ && for file in $(config_files); do ln -nfs .ps-sparky/$$file .$$file; done

check-dead:
	@find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -print

clean-dead:
	@find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -delete

update:
	git pull --rebase

.PHONY: link check-dead clean-dead update
