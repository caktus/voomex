# Voomex

* [![CircleCI](https://circleci.com/gh/caktus/voomex.svg?style=svg)](https://circleci.com/gh/caktus/voomex)

To start your Phoenix server:

  * Complete local dev setup (see below)
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Local dev setup

We use [pre-commit](https://pre-commit.com/) to format and test our code.

To run a fake SMPP server (MC), we're currently using [this docker
image](https://hub.docker.com/r/kk1983/smpp/). The docker-compose file in this repo will
start up 2 fake servers. Fake Almadar is listening for SMPP connections on port 2775 and
HTTP connections on port 88. Fake Libyana is listening for SMPP connections on port 2776 and
HTTP connections on port 89.

```
docker-compose up
```

The steps above should get you running. You can also make local configurations which won't go into
version control. As an example, if you want the app to connect to Postgresql via unix domain
sockets, add this to `config/dev.secret.exs`:

```
import Config

config :voomex, Voomex.Repo,
  socket_dir: "/var/run/postgresql",
```

To run the Phoenix server, while also having a command line to inspect stuff (but note
that the Oban jobs will not run in that scenario):

```
iex -S mix phx.server
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
