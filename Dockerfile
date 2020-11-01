FROM alpine:latest as builder
ENV BRANCH master
RUN apk add --no-cache git build-base cmake bzip2-dev lua5.1 lua5.1-dev

RUN git clone https://github.com/lneto/luadata.git &&               \
    sed -i 's#-fPIC#-fPIC -I/usr/include/lua5.1#g'                  \
    /luadata/GNUmakefile /luadata/Makefile && cd luadata && make    

FROM openresty/openresty:alpine-fat
RUN apk add lua lua-dev
RUN opm install                                       \
			bungle/lua-resty-prettycjson										\
      bungle/lua-resty-template                       \
      bungle/lua-resty-reqargs                        \
      jprjr/lua-resty-exec                            \
      agentzh/lua-resty-http                          \
      thibaultcha/lua-resty-jit-uuid

RUN luarocks install inspect
RUN luarocks install router
RUN luarocks install luasocket

COPY --from=builder /luadata/data.so /usr/local/openresty/lualib/data.so
COPY files/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY files/nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD --chown=nobody:nogroup https://raw.githubusercontent.com/9mine/9mine/master/libs/9p.lua /usr/local/openresty/lualib/9p.lua

ENTRYPOINT [ "sh", "-c", "openresty -g 'daemon off;'" ]
#ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
