#!/usr/bin/env bash
# Construcción en Render: instala gemas, compila assets y prepara la base (Neon).
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
bin/rails db:prepare
