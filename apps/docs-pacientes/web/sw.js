// Service worker: guarda só a casca do app (HTML, CSS, JS, ícones) para abrir rápido e instalar.
// Nunca guarda respostas da API nem PDFs: dado de saúde não fica no aparelho.
const CACHE = "casca-v1";
const CASCA = ["/", "/index.html", "/estilo.css", "/app.js", "/manifest.webmanifest", "/icones/icone.svg"];
self.addEventListener("install", (e) => e.waitUntil(caches.open(CACHE).then((c) => c.addAll(CASCA)).then(() => self.skipWaiting())));
self.addEventListener("activate", (e) => e.waitUntil(caches.keys().then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))));
self.addEventListener("fetch", (e) => {
  const u = new URL(e.request.url);
  if (e.request.method !== "GET" || u.origin !== location.origin || u.pathname.startsWith("/api/") || u.pathname === "/config.json") return;
  e.respondWith(fetch(e.request).catch(() => caches.match(e.request).then((r) => r || caches.match("/index.html"))));
});
