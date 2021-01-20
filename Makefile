.DEFAULT_GOAL      := help
OS                 := $(shell uname)
BIN                := /usr/bin
MACPORTS_BIN       := $(HOME)/macports/bin
VPATH              := $(MACPORTS_BIN)
INSTALL            := $(BIN)/install
AWK                := $(BIN)/awk
SED                := $(BIN)/sed
UNZIP              := $(BIN)/unzip
TAR                := $(BIN)/tar
CURL               := $(BIN)/curl
TOUCH              := $(BIN)/touch
KUBECTL            := kubectl
TMP                := /tmp
SHASUM256          := shasum -a 256
ZSHRC_SRC          := .zshrc
ZSHRC_DST          := $(HOME)/$(ZSHRC_SRC)
ZSHENV_SRC         := .zshenv
ZSHENV_DST         := $(HOME)/$(ZSHENV_SRC)
OHMYZSH_URL        := https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
OHMYZSH_DST        := $(HOME)/.oh-my-zsh
OHMYZSH_THEME_SRC  := richardpct.zsh-theme
OHMYZSH_THEME_DST  := $(HOME)/.oh-my-zsh/themes/$(OHMYZSH_THEME_SRC)
TMUX_SRC           := .tmux.conf
TMUX_DST           := $(HOME)/$(TMUX_SRC)
VIM_SRC            := .vimrc
VIM_DST            := $(HOME)/$(VIM_SRC)
VIM_THEME_SRC      := .vim/colors/beautiful.vim
VIM_THEME_DST      := $(HOME)/$(VIM_THEME_SRC)
VIM_GO_REPO        := https://github.com/fatih/vim-go.git
VIM_GO_DST         := $(HOME)/.vim/pack/plugins/start/vim-go
VIM_RAINBOW_REPO   := https://github.com/luochen1990/rainbow
K8S_STATUS_SRC     := k8s-status.sh
K8S_STATUS_DST     := $(HOME)/$(K8S_STATUS_SRC)
KUBECTL_COMPLETION := $(HOME)/.kubectl_completion
MACPORTS_VERS      := 2.6.4
MACPORTS_URL       := https://distfiles.macports.org/MacPorts
MACPORTS_TAR       := MacPorts-$(MACPORTS_VERS).tar.gz

# $(call copy-file,FILE_SRC,FILE_DST)
define copy-file
  @if [ "$$($(SHASUM256) $1 2> /dev/null | $(AWK) '{print $$1}')" != "$$($(SHASUM256) $2 2> /dev/null | $(AWK) '{print $$1}')" ]; \
  then \
    cp -v $1 $2; \
  fi
endef

.PHONY: help
help: ## Show help
	@echo "Usage: make TARGET\n"
	@echo "Targets:"
	@$(AWK) -F ":.* ##" '/^[^#].*:.*##/{printf "%-13s%s\n", $$1, $$2}' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: all
ifeq "$(OS)" "Darwin"
all: zsh tmux vim kubectl macports ## Install All
else
all: zsh tmux vim kubectl
endif

.PHONY: zsh
zsh: zshenv ohmyzsh $(OHMYZSH_THEME_DST) $(ZSHRC_DST) ## Install .zshrc

.PHONY: $(ZSHRC_DST)
$(ZSHRC_DST): $(ZSHRC_SRC)
	$(call copy-file,$<,$@)

.PHONY: zshenv
zshenv: $(ZSHENV_DST) ## Install .zshenv

.PHONY: $(ZSHENV_DST)
$(ZSHENV_DST): $(ZSHENV_SRC)
	$(call copy-file,$<,$@)

.PHONY: ohmyzsh
ohmyzsh: $(OHMYZSH_DST) ## Install ohmyzsh

$(OHMYZSH_DST):
ifeq "$(OS)" "Darwin"
	sh -c "$$(curl -fsSL $(OHMYZSH_URL))"
else
	echo "n" | sh -c "$$(curl -fsSL $(OHMYZSH_URL))"
endif

.PHONY: $(OHMYZSH_THEME_DST)
$(OHMYZSH_THEME_DST): $(OHMYZSH_THEME_SRC)
	$(call copy-file,$<,$@)

.PHONY: $(K8S_STATUS_DST)
$(K8S_STATUS_DST): $(K8S_STATUS_SRC)
	$(call copy-file,$<,$@)

.PHONY: tmux
tmux: $(K8S_STATUS_DST) $(TMUX_DST) ## Install .tmux.conf

.PHONY: $(TMUX_DST)
$(TMUX_DST): $(TMUX_SRC)
	$(call copy-file,$<,$@)

.PHONY: vim
vim:  $(VIM_DST) ## Install .vimrc

.PHONY: $(VIM_DST)
$(VIM_DST): $(VIM_SRC) $(VIM_THEME_DST) $(VIM_GO_DST)
	$(call copy-file,$<,$@)

.PHONY: $(VIM_THEME_DST)
$(VIM_THEME_DST): $(VIM_THEME_SRC) $(HOME)/.vim/colors $(HOME)/.vim/plugin/rainbow_main.vim
	$(call copy-file,$<,$@)

$(HOME)/.vim/colors:
	mkdir -p $@

$(VIM_GO_DST):
	git clone $(VIM_GO_REPO) $@

$(HOME)/.vim/plugin/rainbow_main.vim:
	if [ ! -d $(HOME)/.vim/plugin ]; \
	then \
		mkdir -p $(HOME)/.vim/plugin; \
	fi

	if [ ! -d $(HOME)/.vim/autoload ]; \
	then \
		mkdir -p $(HOME)/.vim/autoload; \
	fi

	rm -rfv /tmp/rainbow
	git clone $(VIM_RAINBOW_REPO) /tmp/rainbow
	cp -v /tmp/rainbow/plugin/rainbow_main.vim $@
	cp -v /tmp/rainbow/autoload/rainbow_main.vim $(HOME)/.vim/autoload/rainbow_main.vim
	cp -v /tmp/rainbow/autoload/rainbow.vim $(HOME)/.vim/autoload/rainbow.vim

.PHONY: kubectl
kubectl: $(KUBECTL_COMPLETION) ## Install kubectl completion

$(KUBECTL_COMPLETION):
	if type kubectl > /dev/null 2>&1; \
	then \
	  $(KUBECTL) completion zsh > $@; \
	fi

.PHONY: macports
macports: $(MACPORTS_BIN)/port ## Install MacPorts

$(MACPORTS_BIN)/port: MACPORTS_SHA256 = $(shell $(CURL) -s -L $(MACPORTS_URL)/MacPorts-$(MACPORTS_VERS).chk.txt | $(AWK) '/^SHA256.*\.tar\.gz/{print $$2}')

$(MACPORTS_BIN)/port:
	if [ "$$($(SHASUM256) $(TMP)/$(MACPORTS_TAR) 2> /dev/null | $(AWK) '{print $$1}')" != $(MACPORTS_SHA256) ]; \
	then \
	  $(CURL) -L $(MACPORTS_URL)/$(MACPORTS_TAR) -o $(TMP)/$(MACPORTS_TAR); \
	fi

	if [ "$$($(SHASUM256) $(TMP)/$(MACPORTS_TAR) 2> /dev/null | $(AWK) '{print $$1}')" != "$(MACPORTS_SHA256)" ]; \
	then \
	  echo "$(MACPORTS_TAR) is corrupted"; \
	  exit 1; \
	fi

	$(TAR) xzvf $(TMP)/$(MACPORTS_TAR) -C $(TMP)

	cd $(TMP)/MacPorts-$(MACPORTS_VERS) && \
		./configure --prefix=$(HOME)/macports --with-no-root-privileges && \
		make && \
		make install
