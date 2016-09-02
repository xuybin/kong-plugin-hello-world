set -e

# export OPENRESTY_INSTALL=$CACHE_DIR/openresty
export LUAROCKS_INSTALL=$CACHE_DIR/luarocks
# export SERF_INSTALL=$CACHE_DIR/serf
export KONG_INSTALL=$CACHE_DIR/kong

mkdir -p $CACHE_DIR

if [ ! "$(ls -A $CACHE_DIR)" ]; then
  # Not in cache

  # ----------------
  # Install Luarocks
  # ----------------
  LUAROCKS_BASE=luarocks-$LUAROCKS
  mkdir -p $LUAROCKS_INSTALL
  git clone https://github.com/keplerproject/luarocks.git $LUAROCKS_BASE

  pushd $LUAROCKS_BASE
    git checkout v$LUAROCKS
    ./configure \
      --prefix=$LUAROCKS_INSTALL \
      --lua-suffix=jit \
      --with-lua=$OPENRESTY_INSTALL/luajit \
      --with-lua-include=$OPENRESTY_INSTALL/luajit/include/luajit-2.1
    make build
    make install
  popd

  rm -rf $LUAROCKS_BASE

  # ----------------
  # Install Kong
  # ----------------
  KONG_BASE=$KONG_INSTALL-$KONG_VERSION
  mkdir -p $KONG_BASE
  pushd $KONG_BASE
  wget -O "precise_all.deb" "https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.precise_all.deb"
  sudo dpkg -i "precise_all.deb" || true
  popd
  rm -rf $KONG_BASE

fi

export PATH=$PATH:$OPENRESTY_INSTALL/nginx/sbin:$OPENRESTY_INSTALL/bin:$LUAROCKS_INSTALL/bin:$SERF_INSTALL

eval `luarocks path`

# # -------------------------------------
# # Install ccm & setup Cassandra cluster
# # -------------------------------------
# if [[ "$TEST_SUITE" != "unit" ]] && [[ "$TEST_SUITE" != "lint" ]]; then
#   pip install --user PyYAML six
#   git clone https://github.com/pcmanus/ccm.git
#   pushd ccm
#     ./setup.py install --user
#   popd
#   ccm create test -v binary:$CASSANDRA -n 1 -d
#   ccm start -v
#   ccm status
# fi

# nginx -V
# resty -V
luarocks --version
kong version
# serf version
