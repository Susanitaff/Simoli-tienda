-- SimOli: catálogo editable con acceso exclusivo de administradora.
-- Aplicar desde el SQL Editor del proyecto Supabase NUEVO dedicado a SimOli.
create schema if not exists private;
create table if not exists public.simoli_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.simoli_products (
  id text primary key check (length(id) between 3 and 80),
  name text not null check(length(trim(name)) >= 2),
  brand text not null default '',
  category text not null default 'Papelería',
  description text not null default '',
  price numeric(12,2) check(price >= 0),
  stock integer check(stock >= 0),
  condition text not null default 'normal' check(condition in ('normal','detail','open')),
  image_url text,
  published boolean not null default false,
  constraint simoli_publish_requires_price_and_stock check (not published or (price is not null and stock is not null)),
  updated_at timestamptz not null default now()
);
create index if not exists simoli_products_published_idx on public.simoli_products(published);
alter table public.simoli_admins enable row level security;
alter table public.simoli_products enable row level security;
revoke all on public.simoli_admins from anon, authenticated;
grant select on public.simoli_admins to authenticated;
revoke all on public.simoli_products from anon, authenticated;
grant select on public.simoli_products to anon, authenticated;
grant insert, update, delete on public.simoli_products to authenticated;
create policy "each admin sees own admin record" on public.simoli_admins
  for select to authenticated using (user_id = (select auth.uid()));
create or replace function private.simoli_is_admin()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists(select 1 from public.simoli_admins where user_id = (select auth.uid())); $$;
revoke all on function private.simoli_is_admin() from public;
grant usage on schema private to authenticated;
grant execute on function private.simoli_is_admin() to authenticated;
create policy "public sees published products" on public.simoli_products
  for select to anon, authenticated using (published);
create policy "admin sees all products" on public.simoli_products
  for select to authenticated using ((select private.simoli_is_admin()));
create policy "admin inserts products" on public.simoli_products
  for insert to authenticated with check ((select private.simoli_is_admin()));
create policy "admin updates products" on public.simoli_products
  for update to authenticated using ((select private.simoli_is_admin()))
  with check ((select private.simoli_is_admin()));
create policy "admin deletes products" on public.simoli_products
  for delete to authenticated using ((select private.simoli_is_admin()));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('simoli-productos','simoli-productos',true,6291456,
  array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy "simoli admin uploads photos" on storage.objects
 for insert to authenticated
 with check (bucket_id='simoli-productos' and (select private.simoli_is_admin()));
create policy "simoli admin replaces photos" on storage.objects
 for update to authenticated
 using (bucket_id='simoli-productos' and (select private.simoli_is_admin()))
 with check (bucket_id='simoli-productos' and (select private.simoli_is_admin()));
create policy "simoli admin deletes photos" on storage.objects
 for delete to authenticated
 using (bucket_id='simoli-productos' and (select private.simoli_is_admin()));

-- Después de crear TU usuario en Authentication -> Users, registrar SU UUID:
-- insert into public.simoli_admins(user_id) values ('TU-UUID-AQUI');
-- IMPORTANTE: no habilitar registros públicos en Authentication.
