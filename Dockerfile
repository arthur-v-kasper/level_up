# syntax=docker/dockerfile:1
# check=error=false

# Define um argumento para configurar o ambiente
ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives aqui
WORKDIR /rails

# Instala pacotes essenciais
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 postgresql-client libpq-dev && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Define o ambiente como variável de ambiente
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV}
ENV NODE_ENV=${RAILS_ENV}
ENV PATH="/rails/bin:/usr/local/bundle/bin:${PATH}"


# Ajusta configuração do Bundler de acordo com o ambiente
ENV BUNDLE_DEPLOYMENT="${RAILS_ENV}" \
  BUNDLE_PATH="/usr/local/bundle"

# Se for desenvolvimento, mantém o grupo `development`
RUN if [ "$RAILS_ENV" = "production" ]; then \
  export BUNDLE_WITHOUT="development"; \
  else \
  export BUNDLE_WITHOUT=""; \
  fi

# Etapa de build para instalar dependências
FROM base AS build

RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential git pkg-config && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copia os arquivos de dependências primeiro para otimizar o cache do Docker
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# Copia o restante da aplicação
COPY . .

# Precompilação de assets apenas se for produção
RUN if [ "$RAILS_ENV" = "production" ]; then \
  SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile; \
  fi

# Etapa final
FROM base

# Copia os artefatos de build
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Ajusta permissões de arquivos do runtime para um usuário não-root
RUN groupadd --system --gid 1000 rails && \
  useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
  chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint para preparar o banco de dados
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Define comandos diferentes para produção e desenvolvimento
CMD if [ "$RAILS_ENV" = "production" ]; then \
  ./bin/thrust bundle exec rails server -b 0.0.0.0; \
  else \
  rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0; \
  fi
