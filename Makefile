.DEFAULT_GOAL      := help
OS                 := $(shell uname)
BIN                := /usr/bin
OPT_LOCAL          := $(HOME)/opt
BIN_LOCAL          := $(HOME)/opt/bin
VPATH              := $(OPT_LOCAL) $(BIN_LOCAL)
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
K8S_STATUS_SRC     := k8s-status.sh
K8S_STATUS_DST     := $(HOME)/$(K8S_STATUS_SRC)
KUBECTL_COMPLETION := $(HOME)/.kubectl_completion
TERRAFORM_VERS     := 0.12.16
TERRAFORM_URL      := https://releases.hashicorp.com/terraform/$(TERRAFORM_VERS)
TERRAFORM_SHA256   := $(TERRAFORM_URL)/terraform_$(TERRAFORM_VERS)_SHA256SUMS
TERRAFORM_ZIP      := terraform_$(TERRAFORM_VERS)_darwin_amd64.zip
GO_VERS            := 1.14.1
GO_URL             := https://dl.google.com/go
GO_SHA256          := https://golang.org/dl/
GO_TAR             := go$(GO_VERS).darwin-amd64.tar.gz
JQ                 := jq-osx-amd64
JQ_VERS            := 1.6
JQ_URL             := https://github.com/stedolan/jq/releases/download/jq-$(JQ_VERS)/$(JQ)
JQ_SHA256          := https://raw.githubusercontent.com/stedolan/jq/master/sig/v$(JQ_VERS)/sha256sum.txt
PIP3               := /usr/bin/pip3
PIP3_LOCAL         := $(HOME)/Library/Python/3.7/bin/pip3
AWSCLI             := $(HOME)/Library/Python/3.7/bin/aws
EKSCTL             := $(BIN_LOCAL)/eksctl
EKSCTL_URL         := https://github.com/weaveworks/eksctl/releases/download/latest_release
EKSCTL_TAR         := eksctl_Darwin_amd64.tar.gz

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
	@$(AWK) -F ":.* ##" '/^[^#].*:.*##/{printf "%-13s%s\n", $$1, $$2}' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: all
ifeq "$(OS)" "Darwin"
all: zsh tmux vim kubectl terraform go jq pip awscli eksctl ## Install All
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
$(VIM_THEME_DST): $(VIM_THEME_SRC) $(HOME)/.vim/colors
	$(call copy-file,$<,$@)

$(HOME)/.vim/colors:
	mkdir -p $@

$(VIM_GO_DST):
	git clone $(VIM_GO_REPO) $@

.PHONY: kubectl
kubectl: $(KUBECTL_COMPLETION) ## Install kubectl completion

$(KUBECTL_COMPLETION):
	if type kubectl > /dev/null 2>&1; \
	then \
	  $(KUBECTL) completion zsh > $@; \
	fi

terraform: ## Install Terraform
	if [ "$$($(CURL) -s $(TERRAFORM_SHA256) | $(AWK) '/darwin_amd64/{print $$1}')" !=  "$$($(SHASUM256) $(TMP)/$(TERRAFORM_ZIP) 2> /dev/null | $(AWK) '{print $$1}')" ]; \
	then \
	  $(CURL) $(TERRAFORM_URL)/$(TERRAFORM_ZIP) -o $(TMP)/$(TERRAFORM_ZIP); \
	fi

	cd $(BIN_LOCAL) && \
	$(UNZIP) $(TMP)/$(TERRAFORM_ZIP)

go: ## Install Go
	if [ "$$($(SHASUM256) $(TMP)/$(GO_TAR) 2> /dev/null | $(AWK) '{print $$1}')" != "$$($(CURL) -s $(GO_SHA256) | $(AWK) 'BEGIN{RS = '\n\n'}/go1.12.7.darwin-amd64.tar.gz/{ print }' | $(SED) -n -e 's/ *<td><tt>\(.*\)<\/tt><\/td>/\1/p')" ]; \
	then \
	  $(CURL) $(GO_URL)/$(GO_TAR) -o $(TMP)/$(GO_TAR); \
	fi

	$(TAR) xzvf $(TMP)/$(GO_TAR) -C $(OPT_LOCAL)

$(JQ):
	if [ "$$($(CURL) -s $(JQ_SHA256) | $(AWK) '/$(JQ)/{print $$1}')" != "$$($(SHASUM256) $(BIN_LOCAL)/$(JQ) 2> /dev/null | $(AWK) '{print $$1}')" ]; \
	then \
	  $(CURL) -L $(JQ_URL) -o $(TMP)/$(JQ); \
	fi

	$(INSTALL) -m 0755 $(TMP)/$(JQ) $(BIN_LOCAL)/$(JQ)

jq: $(JQ) ## Install jq
	cd $(BIN_LOCAL) && \
	ln -s $< $@

.PHONY: pip
pip: $(PIP3_LOCAL) ## Install pip3

$(PIP3_LOCAL):
	$(PIP3) install --upgrade --user pip

.PHONY: awscli
awscli: $(AWSCLI) ## Install awscli

$(AWSCLI): $(PIP3_LOCAL)
	$< install --upgrade --user awscli

.PHONY: eksctl
eksctl: $(EKSCTL) ## Install eksctl

$(EKSCTL): EKSCTL_SHA256 = $(shell $(CURL) -s -L https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_checksums.txt | $(AWK) '/Darwin/{print $$1}')

$(EKSCTL): $(AWSCLI)
	if [ "$$($(SHASUM256) $(TMP)/$(EKSCTL_TAR) 2> /dev/null | $(AWK) '{print $$1}')" != $(EKSCTL_SHA256) ]; \
	then \
	  $(CURL) -L $(EKSCTL_URL)/$(EKSCTL_TAR) -o $(TMP)/$(EKSCTL_TAR); \
	fi

	if [ "$$($(SHASUM256) $(TMP)/$(EKSCTL_TAR) 2> /dev/null | $(AWK) '{print $$1}')" != "$(EKSCTL_SHA256)" ]; \
	then \
	  echo "$(EKSCTL_TAR) is corrupted"; \
	  exit 1; \
	fi

	$(TAR) xzvf $(TMP)/$(EKSCTL_TAR) -C $(BIN_LOCAL)
	$(TOUCH) $(EKSCTL)
