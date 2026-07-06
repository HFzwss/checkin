-- ============================================
-- 💕 不生气打卡 - Supabase 数据库初始化
-- 在 Supabase SQL Editor 中一次性运行全部
-- ============================================

-- 1. 用户资料表（解决跨用户读取昵称的问题）
create table if not exists profiles (
  id         uuid primary key references auth.users on delete cascade,
  nickname   text not null default '',
  email      text not null default '',
  updated_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Anyone can read profiles"
  on profiles for select to authenticated using (true);

create policy "Users insert own profile"
  on profiles for insert to authenticated with check (auth.uid() = id);

create policy "Users update own profile"
  on profiles for update to authenticated using (auth.uid() = id);

-- 自动创建 profile（新用户注册时触发）
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, nickname, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nickname', new.email),
    new.email
  );
  return new;
end;
$$ language plpgsql security definer;

-- 如果触发器已存在则跳过
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- 2. 打卡记录表
create table if not exists checkins (
  id         uuid default gen_random_uuid() primary key,
  user_id    uuid references auth.users not null,
  date       date not null,
  mood       text not null check (mood in ('happy', 'angry')),
  note       text default '',
  image_url  text default '',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, date)
);

-- 2. 启用 RLS
alter table checkins enable row level security;

-- 3. RLS 策略：所有人可读（伴侣互看）
create policy "Anyone can read checkins"
  on checkins for select
  to authenticated
  using (true);

-- 4. RLS 策略：只能写自己的记录
create policy "Users insert own checkins"
  on checkins for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own checkins"
  on checkins for update
  to authenticated
  using (auth.uid() = user_id);

create policy "Users delete own checkins"
  on checkins for delete
  to authenticated
  using (auth.uid() = user_id);

-- 5. 自动更新 updated_at
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger checkins_updated_at
  before update on checkins
  for each row execute function update_updated_at();

-- 6. 图片存储桶
insert into storage.buckets (id, name, public)
values ('checkin-images', 'checkin-images', true)
on conflict (id) do nothing;

-- 7. Storage 策略
create policy "Anyone can read images"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'checkin-images');

create policy "Anyone can upload images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'checkin-images');

create policy "Anyone can delete own images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'checkin-images' and auth.uid() = owner);

-- 8. 创建索引（加速日期查询）
create index if not exists idx_checkins_date on checkins(date);
create index if not exists idx_checkins_user_date on checkins(user_id, date);

-- 9. 安全问答字段（忘记密码用）
alter table profiles add column if not exists security_question text default '';
alter table profiles add column if not exists security_answer_hash text default '';
alter table profiles add column if not exists failed_logins int default 0;
alter table profiles add column if not exists last_failed_login timestamptz;
alter table profiles add column if not exists partner_id uuid references auth.users;
