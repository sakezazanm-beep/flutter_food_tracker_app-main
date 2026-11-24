-- Food Tracker schema for Supabase. Run in the Supabase SQL Editor.
create table if not exists public.food_tracker_tb (
  id uuid primary key,
  "foodName" text not null,
  "foodMeal" text not null check ("foodMeal" in ('เช้า', 'กลางวัน', 'เย็น', 'ว่าง')),
  "foodAmount" numeric(10,2) not null default 0,
  "foodPeople" integer not null default 1 check ("foodPeople" > 0),
  "foodDate" date not null,
  "foodImage" text,
  user_id uuid not null references auth.users(id) on delete cascade,
  "createdAt" timestamptz not null default now()
);

alter table public.food_tracker_tb add column if not exists "foodAmount" numeric(10,2) not null default 0;
alter table public.food_tracker_tb add column if not exists "foodPeople" integer not null default 1;

alter table public.food_tracker_tb enable row level security;
drop policy if exists "Users read their own food" on public.food_tracker_tb;
create policy "Users read their own food" on public.food_tracker_tb
  for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "Users add their own food" on public.food_tracker_tb;
create policy "Users add their own food" on public.food_tracker_tb
  for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Users update their own food" on public.food_tracker_tb;
create policy "Users update their own food" on public.food_tracker_tb
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
drop policy if exists "Users delete their own food" on public.food_tracker_tb;
create policy "Users delete their own food" on public.food_tracker_tb
  for delete to authenticated using ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public)
values ('food_tracker_bk', 'food_tracker_bk', true)
on conflict (id) do update set public = true;

drop policy if exists "Users upload their own food photos" on storage.objects;
create policy "Users upload their own food photos" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'food_tracker_bk'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
drop policy if exists "Users update their own food photos" on storage.objects;
create policy "Users update their own food photos" on storage.objects
  for update to authenticated using (
    bucket_id = 'food_tracker_bk'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  ) with check (
    bucket_id = 'food_tracker_bk'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
drop policy if exists "Users delete their own food photos" on storage.objects;
create policy "Users delete their own food photos" on storage.objects
  for delete to authenticated using (
    bucket_id = 'food_tracker_bk'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- The bucket is public for photo display. Write/delete access remains scoped to each user folder.
