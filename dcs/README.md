# Docker Compose tools

## What is this?

This is a list of web development tools started in containers.

It starts Traefik on 127.0.0.2 to proxy to containers by labels:

```sh
PROJECT=$(pwd | sed 's#[/.]#-#g; s/^-//g')
docker compose -p "$PROJECT" up -d
```

Optionally you can start Nginx Proxy Manager on 127.0.0.3 for a UI to manage
poxing to other containers:

```sh
PROJECT=$(pwd | sed 's#[/.]#-#g; s/^-//g')
docker compose -p "$PROJECT" -f docker-compose.yml -f docker-compose.npm.yml up -d
```

## TLS proxy

There are two ways to proxy an HTTPS website through traefik:
pasthrough or HTTPS -> HTTP.

In pasthrough mode the target server implements HTTPS
(no certificate needed for traefik).

In HTTPS -> HTTP mode traefik needs a valid TLS certificate.

For containers started here there is `server.pem` certificate,
signed with self-signed root CA: `ca/duzun_root_CA.crt`.

`ca/duzun_root_CA.crt` must be in the trusted root ca
(see https://www.archlinux.org/news/ca-certificates-update/).

If you use Firefox as a browser you will need to import the public ca.crt certificate into Firefox directly.
Firefox does not use the local operating system’s certificate store:
    https://support.mozilla.org/en-US/kb/setting-certificate-authorities-firefox

If you are using your CA to integrate with a Windows environment or desktop computers, please see the documentation on how to use certutil.exe:
    https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/certutil#-installcert

## Services

### `traefik`

Automatic routing of traffic.
Access at [traefik.lh](http://traefik.lh), after adding to `/etc/hosts` as
`127.0.0.2 traefik.lh`.

Add domains to be routed through `traefik` to `/etc/hosts` with IP `127.0.0.2`.

### `npm`
Nxing Proxy Manager - UI for setting up routing.

To access the UI through traefik, add `127.0.0.2 npm.lh` to `/etc/hosts`.
Then access at [npm.lh](http://npm.lh).

Add domains to be routed through `npm` to `/etc/hosts` with IP `127.0.0.3`.

### `portainer`

Docker management UI.

Access at [portainer.lh](http://portainer.lh), after adding to `/etc/hosts` as
`127.0.0.2 portainer.lh`.

### `mailhog`

SMTP with Web UI for testing email sending.

Access at [mailhog.lh](http://mailhog.lh), after adding to `/etc/hosts` as
`127.0.0.2 mailhog.lh`.
