// Panel de krarupOS (lo usa el aspecto global com.krarupos.desktop).
// A la derecha, centrado, pegado al borde, esquiva las ventanas, ajustado al contenido y transparente
// (el fondo invisible viene del tema, panel-background.svgz en build.sh). Los puntos de las apps abiertas vienen de tasks.svgz. No flotante: al pasar de
// flotante a pegado (cuando se acerca una ventana) la zona de clics quedaba desactualizada y el
// triángulo de la bandeja no abría (el clic llegaba al escritorio).
var panel = new Panel
panel.location = "right"
panel.height = 66
panel.floating = false
panel.lengthMode = "fit"
panel.alignment = "center"
panel.opacity = "translucent"
panel.hiding = "dodgewindows"

var kickoff = panel.addWidget("org.kde.plasma.kickoff")
kickoff.currentConfigGroup = ["General"]
kickoff.writeConfig("icon", "org.alienarena.alienarena")
// Tamaño con que se abre la primera vez (el de Seba en 4K); después KDE guarda
// el que deje cada usuario al agrandarlo o achicarlo.
kickoff.currentConfigGroup = []
kickoff.writeConfig("popupWidth", 816)
kickoff.writeConfig("popupHeight", 684)

var tareas = panel.addWidget("org.kde.plasma.icontasks")
tareas.currentConfigGroup = ["General"]
tareas.writeConfig("launchers", [
    "preferred://browser",
    "applications:systemsettings.desktop",
    "applications:org.kde.konsole.desktop",
    "preferred://filemanager",
    "applications:io.missioncenter.MissionCenter.desktop"
])

panel.addWidget("org.kde.plasma.marginsseparator")

// Bandeja: siempre visibles el volumen, el bluetooth y la red; el resto oculto
// (sigue funcionando, se ve con la flecha).
var bandeja = panel.addWidget("org.kde.plasma.systemtray")
bandeja.currentConfigGroup = ["General"]
bandeja.writeConfig("shownItems", ["org.kde.plasma.volume", "org.kde.plasma.bluetooth", "org.kde.plasma.networkmanagement"])
bandeja.writeConfig("hiddenItems", ["org.kde.kdeconnect", "org.kde.plasma.vault", "org.kde.kscreen", "org.kde.plasma.battery", "org.kde.plasma.brightness", "org.kde.plasma.cameraindicator", "org.kde.plasma.clipboard", "org.kde.plasma.devicenotifier", "org.kde.plasma.keyboardindicator", "org.kde.plasma.keyboardlayout", "org.kde.plasma.manage-inputmethod", "org.kde.plasma.mediacontroller", "org.kde.plasma.notifications", "org.kde.plasma.printmanager", "org.kde.plasma.weather", "steam", "TelegramDesktop", "Xwayland Video Bridge"])

var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}

// Reloj en el escritorio de la pantalla principal, abajo a la izquierda junto al
// logo krarupOS del fondo (no en el panel): solo la hora, sin la fecha (se ve al
// hacer clic). Donde lo dejó Seba: 544,2000 en 4K y 272,976 en 1080p, siempre
// 64x64 (el mínimo de Plasma en el escritorio); x proporcional, y entre esos dos
// puntos. Lo mismo en /usr/libexec/krarupos-reloj, que lo reubica al cambiar de
// resolución.
for (var j = 0; j < desktopsArray.length; j++) {
    var escritorio = desktopsArray[j];
    if (escritorio.screen != 0) continue;
    var g = screenGeometry(escritorio.screen);
    var reloj = escritorio.addWidget("org.kde.plasma.digitalclock",
        Math.round(g.width * 544 / 3840), Math.round(976 + (g.height - 1080) * 1024 / 1080), 64, 64);
    reloj.currentConfigGroup = ["Appearance"];
    reloj.writeConfig("showDate", false);
    // Número y no nombre: con "Never" (texto) quedaba mostrando los segundos.
    reloj.writeConfig("showSeconds", 0);
    break;
}
