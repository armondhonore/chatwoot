# Nexlayer deploy image for Chatwoot.
#
# Chatwoot ships a fully-built official image (gems + assets baked in) but its
# default CMD is `irb` — it does NOT start the Rails server. The Nexlayer YAML
# schema has no command/entrypoint override, so we bake the correct startup
# command into a thin wrapper over the official image here.
#
# Building Chatwoot from source under Kaniko repeatedly produced a broken bundle
# path (`bundler: command not found: rails`). The official image's gems live at
# /gems/ruby and `bundle exec rails` resolves correctly, so we reuse it as-is.
#
# Pin to the version tracked in VERSION_CW. The Nexlayer pipeline rewrites this
# FROM to mirror.gcr.io automatically.
FROM chatwoot/chatwoot:v4.15.1

WORKDIR /app

ENV RAILS_ENV=production \
    NODE_ENV=production \
    INSTALLATION_ENV=docker \
    RAILS_LOG_TO_STDOUT=true \
    PORT=3000

EXPOSE 3000

# Run DB migrations/prepare on boot (idempotent), then start the Rails server.
# rails db:chatwoot_prepare creates the DB, enables the pgvector extension, and
# loads the schema on first boot; on subsequent boots it just runs migrations.
CMD ["sh", "-c", "bundle exec rails db:chatwoot_prepare && bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
