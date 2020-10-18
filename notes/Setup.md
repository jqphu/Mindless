Setup!

# Local Dev

## Server

1. `systemctl restart nginx.service`

Enable the server endpoints. This assumes you have an endpoint set up in nginx that looks like:

```
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location /mindless {
      proxy_pass http://localhost:8000/mindless/;
    }
}
```

2. `cargo_wrap run --type api`

Launch the endpoint.

3. `api/scripts/generate_json_request.py`

Fill the server with dummy data.

## Client

[Optional] Launch Android Studio and set up an emulator. If you want to use an Android device
directly then you don't need an emulator.

1. `flutter run`

That's all :)

r for soft refresh (restart the view?), R for hard restart (restart whole app).
