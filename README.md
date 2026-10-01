# Sala Norte — Sistema de cine

Aplicación Rails para gestionar la boletería de una cadena de cines: sedes, salas con su mapa de asientos, películas, funciones y venta de entradas.

## Requisitos

- Ruby 3.3
- SQLite 3

## Puesta en marcha

```bash
bundle install
bin/rails db:setup      # crea la base, carga el esquema y los datos de ejemplo
bin/rails server
```

Para reiniciar los datos: `bin/rails db:seed:replant`.

## Back-office

URL: http://localhost:3000/admin

| Usuario | Contraseña |
|---|---|
| admin@salanorte.com | password123 |

Solo los usuarios con rol **Administrador** pueden ingresar. Los clientes de ejemplo (`maria@example.com`, `juan@example.com`, `lucia@example.com`, contraseña `password123`) no tienen acceso.

Secciones: Sedes, Salas (con mapa de asientos y marcado de movilidad reducida), Películas (con póster vía Active Storage), Funciones, Compras (venta de entradas eligiendo asientos, pago y cancelación) y Usuarios.

## API (`/api/v1`)

Responde siempre JSON. Los endpoints protegidos requieren el header `Authorization: Bearer <token>`; el token se obtiene con el login (o al registrarse).

En [`docs/sala_norte.postman_collection.json`](docs/sala_norte.postman_collection.json) hay una colección de Postman lista para importar; ejecutando las requests en orden, el token y los IDs se guardan solos.

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/api/v1/login` | — | Login con `email_address` y `password`. Devuelve `token`. |
| DELETE | `/api/v1/logout` | ✔ | Invalida el token. |
| POST | `/api/v1/users` | — | Registro de cliente (`user: {name, email_address, password, password_confirmation}`). Envía mail de bienvenida. |
| GET | `/api/v1/profile` | ✔ | Datos del usuario autenticado. |
| GET | `/api/v1/cinemas` | — | Sedes. |
| GET | `/api/v1/movies` | — | Cartelera. `?status=coming_soon` para próximos estrenos. |
| GET | `/api/v1/movies/:id` | — | Detalle con próximas funciones. Filtros: `?cinema_id=` y `?date=AAAA-MM-DD`. |
| GET | `/api/v1/screenings/:id` | — | Función con el mapa de asientos (`taken: true/false`). |
| GET | `/api/v1/orders` | ✔ | Compras del usuario ("Mis entradas"). |
| GET | `/api/v1/orders/:id` | ✔ | Detalle de una compra propia. |
| POST | `/api/v1/orders` | ✔ | Compra: `order: {screening_id, seat_ids: []}`. |
| PATCH | `/api/v1/orders/:id/pay` | ✔ | Marca la compra como pagada (simula el pago) y envía el mail de confirmación. |
| PATCH | `/api/v1/orders/:id/cancel` | ✔ | Cancela la compra y libera los asientos. |

Errores: `401` sin token o token inválido, `404` recurso inexistente (o compra de otro usuario), `422` validación fallida con `details`, `400` parámetros faltantes.

## Emails (Action Mailer)

- **Confirmación de compra**: se envía al pasar una compra a *pagada* (desde la API o el back-office).
- **Bienvenida**: al registrarse por la API.
- **Recuperación de contraseña**: desde la pantalla de login.

En desarrollo los mails no se envían de verdad: se ven en el log o en las vistas previas en http://localhost:3000/rails/mailers.

## Modelo de datos

| Modelo | Descripción | Relaciones |
|---|---|---|
| `User` | Administradores y clientes (`role`) | tiene muchas `Order` |
| `Cinema` | Sede del cine | tiene muchas `Hall` |
| `Hall` | Sala (estándar, 3D o IMAX) con filas × asientos | pertenece a `Cinema`; tiene muchos `Seat` y `Screening` |
| `Seat` | Butaca (fila + número, movilidad reducida) | pertenece a `Hall` |
| `Movie` | Película con póster adjunto | tiene muchas `Screening` |
| `Screening` | Función: película en una sala a una hora, con formato, idioma y precio | pertenece a `Movie` y `Hall`; tiene muchas `Order` y `Ticket` |
| `Order` | Compra de un usuario para una función (pendiente, pagada, cancelada) | pertenece a `User` y `Screening`; tiene muchos `Ticket` |
| `Ticket` | Entrada para un asiento en una función, con código único | pertenece a `Order`, `Screening` y `Seat` |

Reglas de negocio principales:

- Los asientos de una sala se generan automáticamente; no se puede cambiar la distribución si ya hay entradas vendidas.
- Una función no puede superponerse con otra en la misma sala (duración de la película + 20 min de limpieza).
- El formato de la función debe ser compatible con la sala (IMAX solo en salas IMAX, 3D en salas 3D o IMAX).
- Un asiento no puede venderse dos veces para la misma función. Cancelar una compra libera sus asientos.
- Máximo 10 entradas por compra; se suma un 10 % de cargo por servicio.

## Calidad

```bash
bin/rails test
bin/rubocop
bin/brakeman
```
