#=======================================================================#
# Default Web Domain Template                                           #
# DO NOT MODIFY THIS FILE! CHANGES WILL BE LOST WHEN REBUILDING DOMAINS #
#=======================================================================#

server {
    listen      %ip%:%web_port%;
    server_name %domain_idn% %alias_idn%;
    root        %docroot%;
    index       index.php index.html index.htm;
    access_log  /var/log/nginx/domains/%domain%.log combined;
    access_log  /var/log/nginx/domains/%domain%.bytes bytes;
    error_log   /var/log/nginx/domains/%domain%.error.log error;

    include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ~ /\.(?!well-known\/) {
        deny all;
        return 404;
    }

    location ~* /(images|cache|media|logs|tmp)/.*\.(php|pl|py|jsp|asp|sh|cgi)$ {
        deny all;
        return 404;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
        location ~* ^.+\.(ogg|ogv|svg|svgz|swf|eot|otf|woff|woff2|mov|mp3|mp4|webm|flv|ttf|rss|atom|jpg|jpeg|gif|png|webp|ico|bmp|mid|midi|wav|rtf|css|js|jar)$ {
            expires 30d;
            fastcgi_hide_header "Set-Cookie";
        }

        location ~ [^/]\.php(/|$) {
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            try_files $uri =404;
            fastcgi_pass %backend_lsnr%;
            fastcgi_index index.php;
            include /etc/nginx/fastcgi_params;
            include %home%/%user%/conf/web/%domain%/nginx.fastcgi_cache.conf*;
            if ($request_uri ~* "/administrator/|index.php") {
                set $no_cache 1;
            }
        }
    }

    location /error/ {
        alias   %home%/%user%/web/%domain%/document_errors/;
    }

    location /vstats/ {
        alias   %home%/%user%/web/%domain%/stats/;
        include %home%/%user%/web/%domain%/stats/auth.conf*;
    }

    include /etc/nginx/conf.d/phpmyadmin.inc*;
    include /etc/nginx/conf.d/phppgadmin.inc*;
    include %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
