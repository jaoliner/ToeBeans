// ============================================================
// Auth helpers + shared nav. Requires supabaseClient.js loaded first.
// ============================================================

async function getSession() {
  const { data } = await sb.auth.getSession();
  return data.session;
}

async function requireAuth() {
  const session = await getSession();
  if (!session) {
    window.location.href = "login.html";
    return null;
  }
  return session;
}

async function signUp(email, password, username) {
  const { data, error } = await sb.auth.signUp({ email, password });
  if (error) return { error };
  // profile row is created after email confirmation via a DB trigger,
  // but we also try here in case confirmation is disabled in your project
  if (data.user) {
    await sb.from("profiles").upsert({ id: data.user.id, username });
  }
  return { data };
}

async function signIn(email, password) {
  return await sb.auth.signInWithPassword({ email, password });
}

async function signOut() {
  await sb.auth.signOut();
  window.location.href = "index.html";
}

async function getUsername(userId) {
  const { data } = await sb.from("profiles").select("username").eq("id", userId).single();
  return data ? data.username : "a volunteer";
}

function timeAgo(dateStr) {
  const diff = (Date.now() - new Date(dateStr).getTime()) / 1000;
  if (diff < 60) return "just now";
  if (diff < 3600) return Math.floor(diff / 60) + "m ago";
  if (diff < 86400) return Math.floor(diff / 3600) + "h ago";
  return Math.floor(diff / 86400) + "d ago";
}

// Renders the top bar + bottom tab bar into #app-nav-top / #app-nav-bottom
// containers that should exist in every page's HTML.
async function renderNav(activePage) {
  const session = await getSession();
  const topEl = document.getElementById("app-nav-top");
  const bottomEl = document.getElementById("app-nav-bottom");

  const whoHtml = session
    ? `<span class="who">signed in <a href="#" onclick="signOut();return false;">sign out</a></span>`
    : `<span class="who"><a href="login.html">sign in</a></span>`;

  if (topEl) {
    topEl.innerHTML = `
      <div class="wrap">
        <div class="brand"><span class="stamp">🐾</span>Cat Ranker</div>
        <nav class="desktop-nav">
          <a href="index.html" class="${activePage === 'feed' ? 'active' : ''}">Feed</a>
          <a href="search.html" class="${activePage === 'search' ? 'active' : ''}">Search</a>
          <a href="rankings.html" class="${activePage === 'rankings' ? 'active' : ''}">My rankings</a>
          <a href="add.html" class="${activePage === 'add' ? 'active' : ''}">Add a cat</a>
        </nav>
        ${whoHtml}
      </div>`;
  }
  if (bottomEl) {
    const tabs = [
      { id: "feed", href: "index.html", glyph: "☰", label: "Feed" },
      { id: "search", href: "search.html", glyph: "⚲", label: "Search" },
      { id: "add", href: "add.html", glyph: "+", label: "Add" },
      { id: "rankings", href: "rankings.html", glyph: "№", label: "Rankings" },
    ];
    bottomEl.innerHTML = tabs.map(t => `
      <a href="${t.href}" class="${activePage === t.id ? 'active' : ''}">
        <span class="glyph">${t.glyph}</span>${t.label}
      </a>`).join("");
  }
  return session;
}
