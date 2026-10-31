# Activar la administración de SimOli 🌸

**Estado:** código y migración subidos a GitHub. Este documento NO indica que la base o la web pública ya estén activadas.

## 0. Seguridad primero
La contraseña de la base apareció en una captura del chat. **Cambiá esa contraseña desde Supabase (Project Settings > Database)** y guardá la nueva en tu administrador de contraseñas. No la pegues en GitHub ni en ChatGPT.

## 1. Confirmar la conexión de GitHub con Supabase
En el proyecto NUEVO `simoli-tienda`, abrí **Project Settings > Integrations > GitHub**.
- Repo: `Susanitaff/Simoli-tienda`
- Rama de producción: `main`
- Working directory: `.` (la carpeta `supabase/` está en la raíz)
- Activar **Deploy to production** para aplicar nuevas migraciones automáticamente.

La migración `supabase/migrations/20261031090000_inicializar_simoli.sql` crea:
- `simoli_products`: catálogo de 65 presentaciones, incluyendo descuentos por embalaje;
- `simoli_admins`: lista de usuarios autorizados;
- políticas **RLS**: visitantes solo leen productos publicados; solo usuarios autorizados pueden crear y editar;
- bucket público de fotos `simoli-productos`, pero la **subida** exige estar autorizado.

Si no estaba conectado GitHub, después de habilitar la integración puede ser necesario volver a ejecutar el deploy desde la pantalla de la integración. **No ejecutar `setup.sql` y `seed.sql` además de la migración**, porque su contenido está incluido en ella.

## 2. Verificar que se aplicó (SQL Editor)
```sql
select count(*) as productos from public.simoli_products;
select relrowsecurity from pg_class where oid = 'public.simoli_products'::regclass;
```
El resultado esperado al empezar es **65 productos** y **RLS = true**. Si aparece 'relation does not exist', todavía falta aplicar la migración.

## 3. Crear tu usuaria administradora (sin registro público)
- En **Authentication > Users**, creá o invitá únicamente tu propia cuenta.
- Deshabilitá registros públicos si no los necesitás.
- Copiá el UUID que aparece al abrir tu usuario en Authentication.
- En SQL Editor, ejecutá lo siguiente, cambiando `TU-UUID-REAL` por ese UUID de Supabase:

```sql
insert into public.simoli_admins(user_id)
values ('TU-UUID-REAL'::uuid)
on conflict(user_id) do nothing;
```

**No mandes la contraseña de tu cuenta ni la contraseña de la base por chat.**

## 4. Conectar el frontend a la base
En **Project Settings > API Keys** (el nombre puede variar) obtené únicamente:
- **Project URL**: `https://<id>.supabase.co`
- **Publishable key**: suele comenzar con `sb_publishable_`

Son valores públicos por diseño, protegidos por las políticas RLS. Pegalos en `public/simoli-config.js` como `supabaseUrl` y `supabasePublishableKey` respectivamente. **No usar nunca `secret`, `service_role`, contraseñas ni tokens privados en este archivo**.

## 5. Publicar la tienda en Cloudflare
El sitio sigue siendo demostrativo hasta publicar el contenido de `public/` en el proyecto de Cloudflare Pages `libreriayregaleria-simoly`.
El workflow `.github/workflows/deploy-cloudflare.yml` espera que guardes en **Settings > Secrets and variables > Actions** de GitHub:
- `CLOUDFLARE_API_TOKEN` (token privado con Cloudflare Pages Edit)
- `CLOUDFLARE_ACCOUNT_ID`

Nunca pegues los secretos en el repositorio ni en el chat. Luego ejecutá **Actions > Publicar SimOli en Cloudflare Pages > Run workflow** y verificá el resultado.

## 6. Probá el funcionamiento
- Entrá a `https://libreriayregaleria-simoly.pages.dev/admin.html`.
- Iniciá sesión con la cuenta autorizada.
- Probá creando un producto **oculto**, con stock y foto reales; confirmá que no aparezca en el catálogo público.
- Publicalo y comprobá que aparezca en el catálogo. Actualizá su precio y stock y volvé a comprobar.
- Abrí una ventana privada del navegador para comprobar que sin iniciar sesión **no** se pueda administrar.

## Por ahora NO hay ventas reales
El carrito actual es una lista de prueba. No se procesan pagos con Mercado Pago y no se descuenta stock automáticamente por compras. Esto se debe implementar con un servidor seguro y notificaciones de pago verificadas antes de vender.
