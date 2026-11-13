#!/usr/bin/env bash
# Arranque en Render. Antes de levantar el servidor se corren los seeds: son
# idempotentes y agregan funciones para hoy y los próximos días, así la
# cartelera del deploy nunca queda vacía (el plan gratis se duerme y se
# vuelve a iniciar seguido).
set -o errexit

bin/rails db:seed
exec bundle exec puma -C config/puma.rb
