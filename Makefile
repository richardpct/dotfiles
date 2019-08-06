.DEFAULT_GOAL    := help
BIN              := /usr/bin
OPT_LOCAL        := $(HOME)/opt
BIN_LOCAL        := $(HOME)/opt/bin
VPATH            := $(HOME)/opt $(HOME)/opt/bin
AWK              := $(BIN)/awk
SED              := $(BIN)/sed
UNZIP            := $(BIN)/unzip
TAR              := $(BIN)/tar
CURL             := $(BIN)/curl
TMP              := /tmp
SHASUM256        := shasum -a 256
BASHRC_SRC       := .bashrc
BASHRC_DST       := $(HOME)/$(BASHRC_SRC)
TMUX_SRC         := .tmux.conf
TMUX_DST         := $(HOME)/$(TMUX_SRC)
VIM_SRC          := .vimrc
VIM_DST          := $(HOME)/$(VIM_SRC)
VIM_THEME_SRC    := .vim/colors/beautiful.vim
VIM_THEME_DST    := $(HOME)/$(VIM_THEME_SRC)
TERRAFORM_VERS   := 0.12.6
TERRAFORM_URL    := https://releases.hashicorp.com/terraform/$(TERRAFORM_VERS)
TERRAFORM_SHA256 := $(TERRAFORM_URL)/terraform_$(TERRAFORM_VERS)_SHA256SUMS
TERRAFORM_ZIP    := terraform_$(TERRAFORM_VERS)_darwin_amd64.zip
GO_VERS          := 1.12.7
GO_URL           := https://dl.google.com/go
GO_SHA256        := https://golang.org/dl/
GO_TAR           := go$(GO_VERS).darwin-amd64.tar.gz

.PHONY: help
help: ## Show help
	@echo "Usage: make TARGET\n"
	@echo "Targets:"
	@$(AWK) -F ":.* ##" '/.*:.*##/{ printf "%-13s%s\n", $$1, $$2 }' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: all
all: bashrc tmux vim_theme vim terraform go ## Install all

.PHONY: bashrc
bashrc: $(BASHRC_SRC) ## Install .bashrc
ifneq ($(shell $(SHASUM256) $(BASHRC_SRC) 2> /dev/null | $(AWK) '{print $$1}'), \
       $(shell $(SHASUM256) $(BASHRC_DST) 2> /dev/null | $(AWK) '{print $$1}'))
	cp $(BASHRC_SRC) $(BASHRC_DST)
endif

.PHONY: tmux
tmux: $(TMUX_SRC) ## Install .tmux.conf
ifneq ($(shell $(SHASUM256) $(TMUX_SRC) 2> /dev/null | $(AWK) '{print $$1}'), \
       $(shell $(SHASUM256) $(TMUX_DST) 2> /dev/null | $(AWK) '{print $$1}'))
	cp $(TMUX_SRC) $(TMUX_DST)
endif

.PHONY: vim_theme
vim_theme: ## Install VIM theme
ifeq "$(wildcard $(HOME)/.vim/colors)" ""
	mkdir -p $(HOME)/.vim/colors
endif
ifneq ($(shell $(SHASUM256) $(VIM_THEME_SRC) 2> /dev/null | $(AWK) '{print $$1}'), \
       $(shell $(SHASUM256) $(VIM_THEME_DST) 2> /dev/null | $(AWK) '{print $$1}'))
	cp $(VIM_THEME_SRC) $(VIM_THEME_DST)
endif

.PHONY: vim
vim: vim_theme ## Install .vimrc
ifneq ($(shell $(SHASUM256) $(VIM_SRC) 2> /dev/null | $(AWK) '{print $$1}'), \
       $(shell $(SHASUM256) $(VIM_DST) 2> /dev/null | $(AWK) '{print $$1}'))
	cp $(VIM_SRC) $(VIM_DST)
endif

terraform: ## Install Terraform
ifneq ($(shell $(CURL) -s $(TERRAFORM_SHA256) | $(AWK) '/darwin_amd64/{print $$1}'), \
       $(shell $(SHASUM256) $(TMP)/$(TERRAFORM_ZIP) 2> /dev/null | $(AWK) '{print $$1}'))
	$(CURL) $(TERRAFORM_URL)/$(TERRAFORM_ZIP) -o $(TMP)/$(TERRAFORM_ZIP)
endif
ifeq "$(wildcard $(BIN_LOCAL))" ""
	mkdir -p $(BIN_LOCAL)
endif
	cd $(BIN_LOCAL) && \
	$(UNZIP) $(TMP)/$(TERRAFORM_ZIP)

go: ## Install GO
ifneq ($(shell $(SHASUM256) $(TMP)/$(GO_TAR) 2> /dev/null | $(AWK) '{print $$1}'), \
       $(shell $(CURL) -s $(GO_SHA256) | $(AWK) 'BEGIN{RS = '\n\n'}/go1.12.7.darwin-amd64.tar.gz/{ print }' | $(SED) -n -e 's/ *<td><tt>\(.*\)<\/tt><\/td>/\1/p'))
	$(CURL) $(GO_URL)/$(GO_TAR) -o $(TMP)/$(GO_TAR)
endif
	$(TAR) xzvf $(TMP)/$(GO_TAR) -C $(OPT_LOCAL)
