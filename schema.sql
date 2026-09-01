-- ============================================================
-- Toe Beans.AI — Supabase schema
-- Run this once in your Supabase project's SQL Editor
-- (Project → SQL Editor → New query → paste all of this → Run)
-- ============================================================

create extension if not exists "pgcrypto";

-- One row per signed-up volunteer
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  created_at timestamptz default now()
);

create table shelters (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text
);

create table cats (
  id uuid primary key default gen_random_uuid(),
  cat_number bigint unique not null default 1,
  name text not null,
  shelter_id uuid references shelters(id),
  shelter_cat_id text,           -- the shelter's own ID/tag number
  breed text,
  age text,
  sex text,
  color text,
  tags text[] default '{}',
  photo_url text,
  notes text,
  added_by uuid references profiles(id),
  created_at timestamptz default now()
);

-- Raw pairwise comparison votes
create table comparisons (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  cat_a_id uuid references cats(id) not null,
  cat_b_id uuid references cats(id) not null,
  winner_id uuid references cats(id) not null,
  created_at timestamptz default now()
);

-- Each volunteer's personal Elo score per cat
create table ratings (
  user_id uuid references profiles(id) not null,
  cat_id uuid references cats(id) not null,
  elo_score numeric default 1500,
  comparisons_count int default 0,
  note text,
  updated_at timestamptz default now(),
  primary key (user_id, cat_id)
);

-- Friend relationships
create table friends (
  id uuid primary key default gen_random_uuid(),
  user_id_1 uuid references profiles(id) not null,
  user_id_2 uuid references profiles(id) not null,
  created_at timestamptz default now(),
  unique(user_id_1, user_id_2)
);

-- Friend requests (pending)
create table friend_requests (
  id uuid primary key default gen_random_uuid(),
  from_user_id uuid references profiles(id) not null,
  to_user_id uuid references profiles(id) not null,
  status text default 'pending', -- 'pending', 'accepted', 'rejected'
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(from_user_id, to_user_id)
);

-- Bucket list / bookmarks
create table bucket_list (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) not null,
  cat_id uuid references cats(id) not null,
  created_at timestamptz default now(),
  unique(user_id, cat_id)
);

-- ============================================================
-- Row Level Security
-- Everything is readable by anyone (it's a shared feed/catalogue).
-- Writes are only allowed as yourself.
-- ============================================================

alter table profiles enable row level security;
alter table shelters enable row level security;
alter table cats enable row level security;
alter table comparisons enable row level security;
alter table ratings enable row level security;
alter table friends enable row level security;
alter table friend_requests enable row level security;
alter table bucket_list enable row level security;

create policy "profiles are publicly readable" on profiles for select using (true);
create policy "users can update their own profile" on profiles for update using (auth.uid() = id);
create policy "users can insert their own profile" on profiles for insert with check (auth.uid() = id);

create policy "shelters are publicly readable" on shelters for select using (true);
create policy "signed in users can add shelters" on shelters for insert with check (auth.uid() is not null);

create policy "cats are publicly readable" on cats for select using (true);
create policy "signed in users can add cats" on cats for insert with check (auth.uid() = added_by);
create policy "users can update their own cats" on cats for update using (auth.uid() = added_by) with check (auth.uid() = added_by);
create policy "signed in users can add photos and notes to any cat" on cats for update using (auth.uid() is not null);

create policy "comparisons are publicly readable" on comparisons for select using (true);
create policy "users can log their own comparisons" on comparisons for insert with check (auth.uid() = user_id);

create policy "ratings are publicly readable" on ratings for select using (true);
create policy "users can write their own ratings" on ratings for insert with check (auth.uid() = user_id);
create policy "users can update their own ratings" on ratings for update using (auth.uid() = user_id);
create policy "users can delete their own ratings" on ratings for delete using (auth.uid() = user_id);

create policy "friends are readable by involved users" on friends for select using (auth.uid() = user_id_1 or auth.uid() = user_id_2);
create policy "users can create friendships" on friends for insert with check (auth.uid() = user_id_1 or auth.uid() = user_id_2);
create policy "users can delete friendships" on friends for delete using (auth.uid() = user_id_1 or auth.uid() = user_id_2);

create policy "friend requests readable by involved users" on friend_requests for select using (auth.uid() = from_user_id or auth.uid() = to_user_id);
create policy "users can send friend requests" on friend_requests for insert with check (auth.uid() = from_user_id);
create policy "users can accept/reject own requests" on friend_requests for update using (auth.uid() = to_user_id);
create policy "users can delete own requests" on friend_requests for delete using (auth.uid() = from_user_id or auth.uid() = to_user_id);

create policy "bucket list is private to user" on bucket_list for select using (auth.uid() = user_id);
create policy "users can add to own bucket list" on bucket_list for insert with check (auth.uid() = user_id);
create policy "users can remove from own bucket list" on bucket_list for delete using (auth.uid() = user_id);

-- Storage bucket used by the Add a cat page for uploaded photos.
-- Create a public bucket named 'cat-photos' in Supabase Storage first,
-- then run these policies in the SQL editor.
create policy "cat photos are publicly readable" on storage.objects
for select using (bucket_id = 'cat-photos');

create policy "signed in users can upload cat photos" on storage.objects
for insert with check (bucket_id = 'cat-photos' and auth.uid() is not null);

-- ============================================================
-- Automatically create a profile row when someone confirms sign-up
-- ============================================================
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
