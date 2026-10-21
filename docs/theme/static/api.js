// The API page's progressive enhancement. The page is complete without it:
// every fold is a native details, and every link is an anchor. This file adds
// a collapse-all toggle, opens the folds around a linked symbol, and filters
// the symbol list as you type.

const api = document.querySelector(".dx-api");
const nav = document.querySelector(".dx-nav");

// Open every details that holds the target, so a link into a folded type or a
// folded "more" lands on visible text.
function reveal(id) {
  const target = id && document.getElementById(id);
  if (!target) return;
  for (let el = target.parentElement; el; el = el.parentElement) {
    if (el.tagName === "DETAILS") el.open = true;
  }
  target.scrollIntoView();
}

function hashId() {
  return decodeURIComponent(location.hash.slice(1));
}

function addToggle() {
  const types = api.querySelectorAll(".dx-type > details");
  if (types.length === 0) return;
  const button = document.createElement("button");
  button.type = "button";
  button.className = "dx-toggle";
  const label = () => {
    const anyOpen = [...types].some((d) => d.open);
    button.textContent = anyOpen ? "[-] collapse all" : "[+] expand all";
    return anyOpen;
  };
  label();
  button.addEventListener("click", () => {
    const open = !label();
    for (const d of types) d.open = open;
    label();
  });
  api.querySelector(".dx-title").after(button);
}

function addFilter() {
  const list = nav.querySelector("ul");
  const pkg = api.dataset.package;
  const prefix = pkg + ".";
  const index = [...api.querySelectorAll("[id]")]
    .filter((el) => el.id.startsWith(prefix))
    .map((el) => {
      const fqn = el.id.slice(prefix.length);
      return { id: el.id, fqn, lower: fqn.toLowerCase(), name: fqn.split(".").pop().toLowerCase() };
    });

  const input = document.createElement("input");
  input.type = "search";
  input.className = "dx-filter";
  input.placeholder = "Filter symbols  /";
  input.setAttribute("aria-label", "Filter symbols");
  const results = document.createElement("ul");
  results.className = "dx-results";
  results.hidden = true;
  nav.prepend(input);
  list.after(results);

  // A name that starts with the query ranks first, then a name that holds it,
  // then any path that holds it. Shorter paths win a tie.
  function rank(entry, q) {
    if (entry.name.startsWith(q)) return 0;
    if (entry.name.includes(q)) return 1;
    if (entry.lower.includes(q)) return 2;
    return -1;
  }

  function render() {
    const q = input.value.trim().toLowerCase();
    list.hidden = q !== "";
    results.hidden = q === "";
    if (q === "") return;
    const hits = index
      .map((entry) => ({ entry, r: rank(entry, q) }))
      .filter((h) => h.r >= 0)
      .sort((a, b) => a.r - b.r || a.entry.fqn.length - b.entry.fqn.length)
      .slice(0, 60);
    results.replaceChildren(
      ...hits.map(({ entry }) => {
        const li = document.createElement("li");
        const a = document.createElement("a");
        a.href = "#" + entry.id;
        const dot = entry.fqn.lastIndexOf(".");
        const path = document.createElement("span");
        path.className = "dx-path";
        path.textContent = dot < 0 ? "" : entry.fqn.slice(0, dot + 1);
        a.append(path, entry.fqn.slice(dot + 1));
        li.append(a);
        return li;
      }),
    );
    if (hits.length === 0) {
      const li = document.createElement("li");
      li.className = "dx-none";
      li.textContent = "No match.";
      results.append(li);
    }
  }

  input.addEventListener("input", render);
  input.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      input.value = "";
      render();
      input.blur();
    } else if (event.key === "Enter") {
      const first = results.querySelector("a");
      if (first) first.click();
    }
  });
  document.addEventListener("keydown", (event) => {
    const typing = event.target.closest("input, textarea, [contenteditable]");
    if (event.key === "/" && !typing && !event.ctrlKey && !event.metaKey && !event.altKey) {
      event.preventDefault();
      input.focus();
      input.select();
    }
  });
}

if (api && nav) {
  addToggle();
  addFilter();
  window.addEventListener("hashchange", () => reveal(hashId()));
  reveal(hashId());
}
