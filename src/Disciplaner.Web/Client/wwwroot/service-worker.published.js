// Production service worker — generated assets list is injected by the Blazor SDK
// as service-worker-assets.js at publish time.
// See: https://learn.microsoft.com/aspnet/core/blazor/progressive-web-app

self.importScripts('./service-worker-assets.js');

self.addEventListener('install',  event => event.waitUntil(onInstall(event)));
self.addEventListener('activate', event => event.waitUntil(onActivate(event)));
self.addEventListener('fetch',    event => event.respondWith(onFetch(event)));
self.addEventListener('message',  event => {
    if (event.data?.type === 'SKIP_WAITING') self.skipWaiting();
});

const cachePrefix = 'disciplaner-';
const cacheName   = `${cachePrefix}${self.assetsManifest.version}`;

// File patterns to precache
const include = [
    /\.dll$/, /\.pdb$/, /\.wasm/, /\.html/, /\.js$/, /\.json$/,
    /\.css$/, /\.woff2?$/, /\.png$/, /\.jpe?g$/, /\.svg$/, /\.ico$/, /\.webmanifest$/
];
// Never cache the service worker itself
const exclude = [/^service-worker\.js$/];

async function onInstall() {
    const requests = self.assetsManifest.assets
        .filter(a => include.some(p => p.test(a.url)))
        .filter(a => !exclude.some(p => p.test(a.url)))
        .map(a => new Request(a.url, { integrity: a.hash, cache: 'no-cache' }));

    const cache = await caches.open(cacheName);
    await cache.addAll(requests);
}

async function onActivate() {
    // Delete stale caches from previous versions
    const keys = await caches.keys();
    await Promise.all(
        keys
            .filter(k => k.startsWith(cachePrefix) && k !== cacheName)
            .map(k => caches.delete(k))
    );
    // Immediately control all open clients (tabs)
    await self.clients.claim();
}

async function onFetch(event) {
    if (event.request.method !== 'GET') return fetch(event.request);

    // Navigation requests → serve index.html from cache (SPA offline shell)
    const req = event.request.mode === 'navigate' ? 'index.html' : event.request;

    const cache  = await caches.open(cacheName);
    const cached = await cache.match(req);
    return cached ?? fetch(event.request);
}
