# Cat Ranker — setup

This is a plain HTML/CSS/JS app (no build step) that talks to a free
Supabase project for the shared database and login. Pages: Feed, Search,
Add a cat, Compare, My rankings, Cat detail, Sign in.

## 1. Create a Supabase project (free)

1. Go to supabase.com and sign up, then "New project."
2. Pick any name and a database password (save it somewhere).
3. Wait ~2 minutes for it to spin up.

## 2. Create the tables

1. In your project, open the **SQL Editor** (left sidebar).
2. Click **New query**, paste in the entire contents of `schema.sql`
   from this folder, and click **Run**.
3. This creates all five tables, turns on Row Level Security, and sets
   up a trigger that auto-creates a profile when someone signs up.

## 3. Turn off email confirmation (recommended for a small volunteer group)

By default Supabase requires clicking a confirmation link before you can
sign in. For a small trusted group this is extra friction you probably
don't need.

- Go to **Authentication → Providers → Email**, and turn off
  "Confirm email." If you'd rather keep it on, that's fine too — people
  will just need to click the link Supabase emails them before signing in.

## 4. Connect the app to your project

1. In Supabase, go to **Project Settings → API**.
2. Copy the **Project URL** and the **anon public** key.
3. Open `js/config.js` in this folder and paste them in:
   ```js
   const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   const SUPABASE_ANON_KEY = "eyJ...";
   ```
   The anon key is meant to be public — it's safe to commit to your repo.
   Real security comes from the Row Level Security policies already set
   up in `schema.sql`.
4. In Supabase, open **Storage** and create a public bucket named
   `cat-photos`. This is what the Add a cat page uploads to when you
   choose a file instead of pasting a URL.
5. In the same project, open **Storage → Policies** for the
   `cat-photos` bucket and allow:
   - public read access for the bucket
   - signed-in users to upload files

   If you prefer SQL, this also works in the SQL Editor:
   ```sql
   create policy "cat photos are publicly readable" on storage.objects
   for select using (bucket_id = 'cat-photos');

   create policy "signed in users can upload cat photos" on storage.objects
   for insert with check (bucket_id = 'cat-photos' and auth.uid() is not null);
   ```

## 5. Upload to your GitHub repo

Upload every file in this folder (keeping the `css/` and `js/`
subfolders) into your `cat-ranker` GitHub repo, replacing the
placeholder `index.html` from setup. Easiest way with no coding
tools installed: on your repo's GitHub page, click **Add file → Upload
files**, drag in the whole folder, and commit.

Your site will update at the same URL as before
(`https://yourusername.github.io/cat-ranker/`) within a minute or two.

## 6. Try it

1. Visit your site, click **sign in → Create an account**, give
   yourself a volunteer name.
2. Add a cat.
3. You'll be walked into a quick compare round once you have 2+ cats
   ranked — that's the Elo-based ranking loop.
4. Check the Feed — it shows activity from everyone who signs up, not
   just you.

## Notes on what's simplified in this first version

- **Ranking placement** compares a new cat against up to 3 random
  already-rated cats rather than doing a full binary-search insertion.
  It's simpler and works well enough at small scale; can be refined later.
- **Photos** can be added either by pasting an image URL or uploading a
  file to the public `cat-photos` Supabase bucket.
- **Shelters** are created automatically the first time someone types a
  new shelter name when adding a cat.
