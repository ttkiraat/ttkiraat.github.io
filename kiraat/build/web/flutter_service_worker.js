'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/index.html": "d9ca0ca597dde9b15918e7837fd1310e",
"/main.dart.js": "a555631de655050f1ed0ce33ec888fec",
"/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/manifest.json": "c01f757ddb4aa14d3085f292263f4e33",
"/assets/LICENSE": "041390cacec7d58caf7b47a42ae38c08",
"/assets/AssetManifest.json": "e3a8a841f0f7eaab38d6acc7f996a103",
"/assets/FontManifest.json": "a41e65e4ed54b0e661257f0b1f26182d",
"/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets/fonts/Amiri-Bold.ttf": "d4bb617dd4d52c1ac69b309ed1a9e961",
"/assets/fonts/Amiri-Regular.ttf": "ca4550ad2edcc95c1086266f83616636",
"/assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request, {
          credentials: 'include'
        });
      })
  );
});
