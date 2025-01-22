# Docker Compose files for Convertigo

Please visit [the main repository](https://github.com/convertigo/convertigo/tree/master)
Or [the official Docker documentation](https://hub.docker.com/_/convertigo)

## Quick start

You can retrieve it in your current directory with:
`curl -sL https://github.com/convertigo/docker/archive/refs/heads/compose.tar.gz | tar xvz --strip-components=1`

Edit the `.env` file then start with `docker compose up -d` and end with `docker compose down`.

All container files are in the `data` folder.

You can also download [repository files in zip](https://github.com/convertigo/docker/archive/refs/heads/compose.zip).

## Configuration

Please edit the `.env` file to enable/disable services and do configurations.

It's recommended to change default password.

## Network Access

By default, only the `http` on port `28080` is exposed to access Convertigo.

If `HTTPD_ENABLE=1`, you can access with `http` on port `80`. This is needed for `CONVERTIGO_MULTI_ENABLE=1` or `BASEROW_ENABLE=1`.

## SSL Configuration

To enable `https` for `convertigo` (on port `28443`) and `httpd` (on port `443`) services, you have to put 2 files: `init/certs/key.pem` (the private key) and `init/certs/full.pem` (the full certificates chain).

Check that `PUBLIC_HOSTNAME` is the same as the certificate and solved by your DNS.

If you want to test with a self-signed certificate (set `CN` the same value as `PUBLIC_HOSTNAME`):
 openssl req -x509 -newkey rsa:4096 -keyout init/certs/key.pem -out init/certs/full.pem -sha256 -days 3650 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

Then `docker compose restart convertigo_0 httpd`.

You can also force `http` access to redirect to the `https` access with `HTTPD_HTTPS_REDIRECT=1`.

## No Code Database

To have a working No Code Database you have to configure the `PUBLIC_HOSTNAME` configured but also `TIMESCALEDB_ENABLE=1`, `HTTPD_ENABLE=1` and `BASEROW_ENABLE=1`. Then access with `http://<hostname>/login`.

If your endpoint is `https` you also have to change the `BASEROW_PUBLIC_URL` with the `https` version.
