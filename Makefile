.DEFAULT_GOAL    := help
BIN              := /usr/bin
OPT_LOCAL        := $(HOME)/opt
BIN_LOCAL        := $(HOME)/opt/bin
VPATH            := $(OPT_LOCAL) $(BIN_LOCAL)
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
TERRAFORM_VERS   := 0.12.8
TERRAFORM_URL    := https://releases.hashicorp.com/terraform/$(TERRAFORM_VERS)
TERRAFORM_SHA256 := $(TERRAFORM_URL)/terraform_$(TERRAFORM_VERS)_SHA256SUMS
TERRAFORM_ZIP    := terraform_$(TERRAFORM_VERS)_darwin_amd64.zip
GO_VERS          := 1.13.1
GO_URL           := https://dl.google.com/go
GO_SHA256        := https://golang.org/dl/
GO_TAR           := go$(GO_VERS).darwin-amd64.tar.gz

# $(call copy-file,FILE_SRC,FILE_DST)
define copy-file
  @if [ "$$($(SHASUM256) $1 2> /dev/null | $(AWK) '{print $$1}')" != "$$($(SHASUM256) $2 2> /dev/null | $(AWK) '{print $$1}')" ]; \
  then \
    cp -v $1 $2; \
  fi
endef

ifeq "$(MAKECMDGOALS)" "$(filter $(MAKECMDGOALS), terraform go)"
  ifeq "$(wildcard $(BIN_LOCAL)/)" ""
    $(shell mkdir $(BIN_LOCAL))
  endif
endif

.PHONY: help
help: ## Show help
	@echo "Usage: make TARGET\n"
	@echo "Targets:"
	@$(AWK) -F ":.* ##" '/^[^#].*:.*##/{printf "%-17s%s\n", $$1, $$2}' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: all
all: $(BASHRC_DST) $(TMUX_DST) $(VIM_DST) $(VIM_THEME_DST) terraform go ## Install all

.PHONY: $(BASHRC_DST)
$(BASHRC_DST): $(BASHRC_SRC) ## Install .bashrc
	$(call copy-file,$<,$@)

.PHONY: $(TMUX_DST)
$(TMUX_DST): $(TMUX_SRC) ## Install .tmux.conf
	$(call copy-file,$<,$@)

.PHONY: $(VIM_DST)
$(VIM_DST): $(VIM_SRC) $(VIM_THEME_DST) ## Install .vimrc
	$(call copy-file,$<,$@)

.PHONY: $(VIM_THEME_DST)
$(VIM_THEME_DST): $(VIM_THEME_SRC) $(HOME)/.vim/colors ## Install VIM theme
	$(call copy-file,$<,$@)

$(HOME)/.vim/colors:
	mkdir -p $@

terraform: ## Install Terraform
	if [ "$$($(CURL) -s $(TERRAFORM_SHA256) | $(AWK) '/darwin_amd64/{print $$1}')" !=  "$$($(SHASUM256) $(TMP)/$(TERRAFORM_ZIP) 2> /dev/null | $(AWK) '{print $$1}')" ]; \
	then \
	  $(CURL) $(TERRAFORM_URL)/$(TERRAFORM_ZIP) -o $(TMP)/$(TERRAFORM_ZIP); \
	fi

	cd $(BIN_LOCAL) && \
	$(UNZIP) $(TMP)/$(TERRAFORM_ZIP)

go: ## Install GO
	if [ "$$($(SHASUM256) $(TMP)/$(GO_TAR) 2> /dev/null | $(AWK) '{print $$1}')" != "$$($(CURL) -s $(GO_SHA256) | $(AWK) 'BEGIN{RS = '\n\n'}/go1.12.7.darwin-amd64.tar.gz/{ print }' | $(SED) -n -e 's/ *<td><tt>\(.*\)<\/tt><\/td>/\1/p')" ]; \
	then \
	  $(CURL) $(GO_URL)/$(GO_TAR) -o $(TMP)/$(GO_TAR); \
	fi

	$(TAR) xzvf $(TMP)/$(GO_TAR) -C $(OPT_LOCAL)
