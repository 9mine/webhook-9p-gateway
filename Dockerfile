FROM openresty/openresty:alpine-fat
RUN opm install                                       \
      bungle/lua-resty-template                       \
      jprjr/lua-resty-exec                            \
      agentzh/lua-resty-http                          \
      thibaultcha/lua-resty-jit-uuid

RUN luarocks install inspect
RUN luarocks install router
RUN luarocks install luasocket

#ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
