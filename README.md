# SimOli 🌸 · Librería y Regalería

Tienda y catálogo de demostración de **SimOli** (Villa Carlos Paz, Córdoba).

## Estado actual
- **Web pública actual:** https://libreriayregaleria-simoly.pages.dev
- **Código nuevo:** `public/index.html` (estética Sakura, catálogo con 58 modelos, 65 presentaciones y fotos originales).
- **Inventario:** `inventario_actualizado.csv`, con referencias de stock, precio sugerido y empaques con detalles.
- **ATENCIÓN:** el código de GitHub no reemplaza automáticamente el sitio público hasta conectar Cloudflare.
- **NO hay cobros con Mercado Pago habilitados.** Carrito demostrativo; no confirmar pedidos reales desde la página.
- Algunas fotos todavía necesitan limpieza de fondo/recorte. NO reemplazar los envases originales por fotografías alteradas.

## Publicación automática a Cloudflare Pages

El proyecto de Cloudflare ya se creó con **Direct Upload**. Se puede mantener su enlace utilizando un workflow de GitHub Actions que despliega con Wrangler, sin recrear el proyecto.

### Paso 1: Guardar la configuración privada de Cloudflare en GitHub
Ir desde el celular a:
https://github.com/Susanitaff/Simoli-tienda/settings/secrets/actions

Crear dos **Repository secrets**, uno a la vez:
- `CLOUDFLARE_API_TOKEN`: token creado en Cloudflare con permiso *Account → Cloudflare Pages → Edit*, restringido a tu cuenta.
- `CLOUDFLARE_ACCOUNT_ID`: identificador de la cuenta que contiene el proyecto Pages.

No mandar valores por WhatsApp, GitHub Issues o chat y no colocarlos en archivos del repositorio.

### Paso 2: Desplegar
Ir a:
https://github.com/Susanitaff/Simoli-tienda/actions/workflows/deploy-cloudflare.yml

Elegir **Run workflow** → **main** → **Run workflow**. Comprobar el resultado y abrir el enlace público.

A partir de ese momento cada actualización a `main` intentará publicarse automáticamente. Si los secretos aún no están configurados, el workflow mostrará una advertencia y NO publicará nada.

### Paso 3: Próximas mejoras
1. Validar cantidades, precios y calidad de fotos de cada presentación (incluidos embalajes con detalles y 5 % de descuento).
2. Separar recursos binarios del HTML para facilitar actualizaciones.
3. Incorporar ventas con Mercado Pago Checkout Pro **solo tras integrar servidor, validación de precios/stock y webhooks**.
4. Agregar solicitud de listas escolares.

## Importante
Los precios son **sugeridos** y algunos requieren reconfirmación frente al mercado.


## Administración desde el celular (preparado, no activado)
- Archivo del panel: `public/admin.html`.
- Administradora: entra con correo y contraseña de **Supabase Auth**, luego se confirma autorización en `simoli_admins` mediante Row Level Security (RLS).
- Operaciones: alta/edición, foto real, precio, stock, ocultar/publicar y estados de empaque.
- **Aún falta enlazar Supabase**. La web seguirá en modo demostración hasta entonces. El panel no está listo para iniciar sesión todavía.
- Scripts: ejecutar primero `supabase/setup.sql` y después `supabase/seed.sql` (65 presentaciones; no sobrescribe productos).
- Crear la usuaria solo desde Supabase Authentication (registro público deshabilitado), autorizar su UUID con el `INSERT` indicado al final de `setup.sql`.
- Configurar ÚNICAMENTE la URL y la **publishable key pública** en `public/simoli-config.js`. Estas son credenciales públicas limitadas por RLS. **Nunca** colocar secret key, service role ni contraseñas en GitHub.
- El código de la tienda leerá el stock y los productos publicados desde Supabase una vez hechos esos pasos. Mientras no esté configurado, conserva la vista de demostración original.
- Publicar en Cloudflare después de revisar el resultado. La tienda sigue sin pagos reales.

## Seguridad y pendientes
- El repositorio figura actualmente **público**, aunque se había pensado hacerlo privado. Si se prefiere privado, cambiarlo desde GitHub → Settings → General → Danger Zone → Change visibility.
- No almacenar tokens, contraseñas ni información de clientes en el código o CSV.
- El panel modifica catálogo, **no** registra ventas reales ni descuenta stock por cobros. Para activar pagos faltan backend, webhooks y validación del stock, además de configurar Mercado Pago en modo prueba.
