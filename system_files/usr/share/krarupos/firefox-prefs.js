// krarupOS: ajustes de rapidez de Firefox (valores por defecto; si el usuario
// cambia uno a mano, gana el del usuario). krarupos-flatpaks los copia en cada
// arranque a la extensión systemconfig.
// Vsync y layout.frame_rate quedan fuera: dependen del monitor de cada equipo.

// Carga anticipada (uBlock "Disable pre-fetching" la apaga: ver firefox-policies.json)
pref("network.http.speculative-parallel-limit", 6);
pref("network.dns.disablePrefetch", false);
pref("network.dns.disablePrefetchFromHTTPS", false);
pref("network.prefetch-next", true);
pref("network.predictor.enabled", true);

// Red y conexiones (Betterfox Fastfox)
pref("network.http.max-connections", 1800);
pref("network.http.max-persistent-connections-per-server", 10);
pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
pref("network.http.pacing.requests.enabled", false);
pref("network.dnsCacheEntries", 10000);
pref("network.dnsCacheExpiration", 3600);
pref("network.ssl_tokens_cache_capacity", 10240);

// Pintado y caché
pref("content.notify.interval", 100000);
pref("gfx.canvas.accelerated.cache-size", 512);
pref("gfx.content.skia-font-cache-size", 20);
pref("media.memory_cache_max_size", 65536);
pref("image.mem.decode_bytes_at_a_time", 32768);

// GPU y video
pref("gfx.webrender.all", true);
pref("media.ffmpeg.vaapi.enabled", true);

// Scroll suave (Betterfox)
pref("apz.overscroll.enabled", true);
pref("general.smoothScroll", true);
pref("general.smoothScroll.msdPhysics.enabled", true);
pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2");
pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
pref("general.smoothScroll.currentVelocityWeighting", "1");
pref("general.smoothScroll.stopDecelerationWeighting", "1");
