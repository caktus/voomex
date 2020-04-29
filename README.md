# Voomex

* [![CircleCI](https://circleci.com/gh/caktus/voomex.svg?style=svg)](https://circleci.com/gh/caktus/voomex)

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Development

We use [pre-commit](https://pre-commit.com/) to format and test our code.

To run a fake SMPP server (MC), we're currently using this docker image:

```
docker run -p 2775:2775 -p 88:88 --name smppsim kk1983/smpp
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
