server {
    listen 80;
    server_name cd-iad-console.peerbelt.link;
    access_log /var/log/nginx/console-pb-access.log;
    error_log /var/log/nginx/console-pb-error.log;
    location / {
        proxy_pass http://localhost:44444;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    location ^~ /api/v1 {
        proxy_pass http://localhost:33333/api;
    }
}

server {
    listen 80;
    server_name cd-iad-www.peerbelt.link;
    access_log /var/log/nginx/www-pb-access.log;
    error_log /var/log/nginx/www-pb-error.log;
    location / {
        proxy_pass http://localhost:44445;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name cd-iad-tracking.peerbelt.link;
    access_log /var/log/nginx/tracking-pb-access.log;
    error_log /var/log/nginx/tracking-pb-error.log;
    location / {
        proxy_pass http://localhost:22222;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name cd-iad-consumer.peerbelt.link;
    access_log /var/log/nginx/consumer-pb-access.log;
    error_log /var/log/nginx/consumer-pb-error.log;
    location / {
        proxy_pass http://localhost:11111;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

