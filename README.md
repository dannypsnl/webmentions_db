# WebmentionsDb

A local cache management system for [webmentions](https://webmention.net/), it daily

- fetch new mentions from https://webmention.io/
- produce mentions tree for each mentioned target (a URL that usually is your site post).

This project only care about work with forester, because that's what I use; it's still possible to support others site, but you will need to modify `Gen.generate` function, I'm welcome any contributions that generalized the interface, so more people can use this project without pain.

## Setup

```sh
git clone https://github.com/dannypsnl/webmentions_db.git
# run database up, this need ./db-data/ directory
docker compose up -d
```

The environment variables you need are

```sh
export DOMAIN=<your site url without scheme>
export TOKEN=<webmention.io token>
```

Then run `mix run script/init.exs` to setup your local database. Since this system can daily update, so it's up to you to run it at background, or use scripts below manually

```sh
mix run script/update.exs
mix run script/generate.exs
```

## Concept

1. A mention is a link that talk about a (target) URL of your site.
2. A mentioned target is a URL under your site.
