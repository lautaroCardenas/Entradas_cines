# CORS: permite que el front-end (React) consuma la API desde otro origen.
# En desarrollo el front usa el proxy de Vite y no lo necesita; sí hace falta
# cuando front y back se publican en dominios distintos.
#
# FRONTEND_ORIGINS acepta varios orígenes separados por coma.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173").split(",").map(&:strip))

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end
