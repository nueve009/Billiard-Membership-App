create table public.members (
	id uuid primary key default gen_random_uuid(),
	auth_user_id uuid unique references auth.users (id) on delete set null,
	full_name text not null check (btrim(full_name) <> ''),
	email text,
	phone text,
	remaining_minutes integer not null default 0 check (remaining_minutes >= 0),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table public.pool_tables (
	id uuid primary key default gen_random_uuid(),
	table_number integer not null unique check (table_number > 0),
	table_type text not null default 'pool'
		check (table_type in ('pool', 'snooker', 'carom')),
	hourly_rate numeric(10, 2) not null check (hourly_rate >= 0),
	status text not null default 'free'
		check (status in ('free', 'in_use', 'reserved')),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table public.sessions (
	id uuid primary key default gen_random_uuid(),
	member_id uuid references public.members (id) on delete set null,
	pool_table_id uuid not null references public.pool_tables (id) on delete restrict,
	started_at timestamptz not null default now(),
	ended_at timestamptz,
	hourly_rate numeric(10, 2) not null check (hourly_rate >= 0),
	minutes_charged integer not null default 0 check (minutes_charged >= 0),
	amount_charged numeric(10, 2) not null default 0 check (amount_charged >= 0),
	created_at timestamptz not null default now(),
	constraint sessions_end_after_start check (ended_at is null or ended_at >= started_at)
);

create index sessions_member_started_at_idx
	on public.sessions (member_id, started_at desc);

create index sessions_pool_table_started_at_idx
	on public.sessions (pool_table_id, started_at desc);

create unique index sessions_one_active_per_pool_table_idx
	on public.sessions (pool_table_id)
	where ended_at is null;

create function public.sync_pool_table_status()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
	if tg_op = 'INSERT' then
		if new.ended_at is null then
			update public.pool_tables
			set status = 'in_use', updated_at = now()
			where id = new.pool_table_id and status = 'free';

			if not found then
				raise exception 'Pool table % is not free', new.pool_table_id;
			end if;
		end if;
		return new;
	elsif tg_op = 'UPDATE' then
		if old.ended_at is null
			 and (new.ended_at is not null or new.pool_table_id <> old.pool_table_id) then
			update public.pool_tables
			set status = 'free', updated_at = now()
			where id = old.pool_table_id and status = 'in_use';
		end if;

		if new.ended_at is null
			 and (old.ended_at is not null or new.pool_table_id <> old.pool_table_id) then
			update public.pool_tables
			set status = 'in_use', updated_at = now()
			where id = new.pool_table_id and status = 'free';

			if not found then
				raise exception 'Pool table % is not free', new.pool_table_id;
			end if;
		end if;
		return new;
	elsif tg_op = 'DELETE' then
		if old.ended_at is null then
			update public.pool_tables
			set status = 'free', updated_at = now()
			where id = old.pool_table_id and status = 'in_use';
		end if;
		return old;
	end if;

	return null;
end;
$$;

revoke execute on function public.sync_pool_table_status() from public, anon, authenticated;

create trigger sessions_sync_pool_table_status
	after insert or update or delete on public.sessions
	for each row execute function public.sync_pool_table_status();

alter table public.members enable row level security;
alter table public.pool_tables enable row level security;
alter table public.sessions enable row level security;

revoke all on table public.members, public.pool_tables, public.sessions from anon, authenticated;
grant select, insert, update, delete on table public.members, public.pool_tables, public.sessions to authenticated;

create policy "Members can read their own profile"
	on public.members for select to authenticated
	using (auth_user_id = (select auth.uid()));

create policy "Staff can read all members"
	on public.members for select to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can create members"
	on public.members for insert to authenticated
	with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can update members"
	on public.members for update to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff')
	with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can delete members"
	on public.members for delete to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Authenticated users can read pool tables"
	on public.pool_tables for select to authenticated
	using (true);

create policy "Staff can create pool tables"
	on public.pool_tables for insert to authenticated
	with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can update pool tables"
	on public.pool_tables for update to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff')
	with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can delete pool tables"
	on public.pool_tables for delete to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Members can read their own sessions"
	on public.sessions for select to authenticated
	using (
		exists (
			select 1
			from public.members
			where members.id = sessions.member_id
				and members.auth_user_id = (select auth.uid())
		)
	);

create policy "Staff can read all sessions"
	on public.sessions for select to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can create sessions"
	on public.sessions for insert to authenticated
	with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can update sessions"
	on public.sessions for update to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff')
	with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');

create policy "Staff can delete sessions"
	on public.sessions for delete to authenticated
	using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'staff');
