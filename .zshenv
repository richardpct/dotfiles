if [ -d /opt/homebrew ]; then
  PATH=$PATH:/opt/homebrew/bin:/opt/homebrew/sbin
fi

if [ -d ~/macports ]; then
  PATH=$PATH:~/macports/bin:~/macports/sbin
fi
