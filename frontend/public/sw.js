const CACHE_NAME = "mindlab-pwa-v1";
const BASE_PATH = "/MindLab_Starter_Project/";
const OFFLINE_URL = BASE_PATH + "offline.html";

const STATIC_ASSETS = [
  OFFLINE_URL,
  BASE_PATH + "manifest.webmanifest",
  BASE_PATH + "icons/icon-192.png",
  BASE_PATH + "icons/icon-512.png",
  BASE_PATH + "icons/maskable-icon-512.png"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(STATIC_ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => Promise.all(
        cacheNames
          .filter((cacheName) => cacheName !== CACHE_NAME)
          .map((cacheName) => caches.delete(cacheName))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;

  if (request.method !== "GET") {
    return;
  }

  const requestUrl = new URL(request.url);

  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request).catch(() => caches.match(OFFLINE_URL))
    );
    return;
  }

  const isApprovedStaticAsset =
    requestUrl.pathname === BASE_PATH + "manifest.webmanifest" ||
    requestUrl.pathname === BASE_PATH + "offline.html" ||
    requestUrl.pathname === BASE_PATH + "icons/icon-192.png" ||
    requestUrl.pathname === BASE_PATH + "icons/icon-512.png" ||
    requestUrl.pathname === BASE_PATH + "icons/maskable-icon-512.png";

  if (isApprovedStaticAsset) {
    event.respondWith(
      caches.match(request).then((cachedResponse) => {
        return cachedResponse || fetch(request).then((networkResponse) => {
          return caches.open(CACHE_NAME).then((cache) => {
            cache.put(request, networkResponse.clone());
            return networkResponse;
          });
        });
      })
    );
  }
});
