'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "0ad1303e5d7bc835f134d9c5e28f9441",
"index.html": "72230d99cf9d0c1277015f24a551c5c4",
"/": "72230d99cf9d0c1277015f24a551c5c4",
"main.dart.js": "95d901761335da07d88a93fc725b25d7",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "59c5c448d9677a9017a0a477c09f2d43",
"firebase-config.js": "3d28307ae6c6f55b6184e04d83680ee5",
"assets/images/rocket_league_logo.png": "7b55982254c05344141272697adcf62e",
"assets/images/logos/full/full-tt.png": "384abc7945e63ac5811bac1850d35308",
"assets/images/logos/full/full-mono-inv.png": "56bca80dae7cd613afd83db4a83a611e",
"assets/images/logos/full/full-color.png": "672ae7bcbc0f34825397bd0deee85b07",
"assets/images/logos/full/full-mono.png": "a0eadc59ab42c5b02805e7a0993af262",
"assets/images/logos/compact/compact-mono-inv.png": "cdb7a545cc1aaf18e6a7c7905823cec4",
"assets/images/logos/compact/compact-tt.png": "ac2a6b3ba5c68fe44d702bb02e4f9bc2",
"assets/images/logos/compact/compact-mono.png": "6c6d1f2278ed7510a0c96b3e83dc65a2",
"assets/images/logos/compact/compact-color.png": "ae3558f108771520f404d8322405d5f5",
"assets/images/logos/abbrev/abbrev-mono.png": "01a0f8a49e1b96e691e01370f0d24fba",
"assets/images/logos/abbrev/abbrev-tt.png": "95cdc65f196c0fe5cd7468cb10bbf2c8",
"assets/images/logos/abbrev/abbrev-color.png": "2cc433a714a18cb20fc597c401e0c66c",
"assets/images/logos/abbrev/abbrev-mono-inv.png": "ced8a1c56ae198944a23821408215670",
"assets/images/logos/icon/mark-mono.png": "73ebe2dbe50ded7ed9a76d06b3cae6a2",
"assets/images/logos/icon/mark-color.png": "6c5ee3cd87bab4b066557c44da8a3140",
"assets/images/logos/icon/mark-tt.png": "8fb284929bde731cf71f741c9dceb649",
"assets/images/steam_logo.png": "28e15ba760eae3c5e6fcadb6b6e2c0ee",
"assets/images/ow_logo.png": "ce34116fecaaa80f7edc4a75da602017",
"assets/images/valorant_logo.png": "583d5f80e46d247b2a28c63262c35161",
"assets/images/splitgate_logo.png": "2026eaab4402c3f6d5a769640848fd4b",
"assets/images/league_logo.png": "24d75b730fd3fcd3d94e7012a90ef72a",
"assets/AssetManifest.json": "6c84efcb0d7a2adc882ecb26901759e3",
"assets/NOTICES": "9e6b8fb369d7094d0829afd7dd0d34b5",
"assets/FontManifest.json": "956e1fabad95ffc42bae02dba30e6a75",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/cool_alert/assets/flare/warning_check.flr": "ff4a110b8d905dedb4d4639a17399703",
"assets/packages/cool_alert/assets/flare/loading.flr": "b6987a8e6de74062b8c002539d2d043e",
"assets/packages/cool_alert/assets/flare/info_check.flr": "f6b81c2aa3ae36418c13bfd36d11ac04",
"assets/packages/cool_alert/assets/flare/success_check.flr": "9d163bcc6f6b58566e0abde7761a67a0",
"assets/packages/cool_alert/assets/flare/error_check.flr": "d9f54791d0d79935d22206966707e4b3",
"assets/fonts/Karla-Italic.ttf": "a399819373a4906b3a9b65755bedb74c",
"assets/fonts/LEMONMILK-BoldItalic.otf": "fe937519187c7ceab5e5e6974b9add5c",
"assets/fonts/Ubuntu-Regular.ttf": "2505bfbd9bde14a7829cc8c242a0d25c",
"assets/fonts/Ubuntu-Bold.ttf": "e00e2a77dd88a8fe75573a5d993af76a",
"assets/fonts/LEMONMILK-RegularItalic.otf": "e8d33233b256559c813a7c19e65914dc",
"assets/fonts/LEMONMILK-Regular.otf": "be29f3c5ccd30b97f9c394a02c9ce5d7",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/fonts/LEMONMILK-Bold.otf": "51cab81ef06302b3a4f10723c2396e83",
"assets/fonts/Ubuntu-BoldItalic.ttf": "48c161df9991f9b0f6e4a858e95e415e",
"assets/fonts/Karla-Regular.ttf": "8f456584c855750cf2eb1c28f39753e5",
"assets/fonts/Karla-BoldItalic.ttf": "133ce9656f506946e7f3535a5e1c3c5d",
"assets/fonts/Ubuntu-Italic.ttf": "4b96047e4af086277cdaeb9e60857534",
"assets/fonts/Karla-Bold.ttf": "008289c29878b73e3dbfbd85d41a75f0"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
