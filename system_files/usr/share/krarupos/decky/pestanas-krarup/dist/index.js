const manifest = {"name":"Tabs krarupOS"};
const API_VERSION = 2;
const internalAPIConnection = window.__DECKY_SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED_deckyLoaderAPIInit;
if (!internalAPIConnection) {
    throw new Error('[@decky/api]: Failed to connect to the loader as as the loader API was not initialized. This is likely a bug in Decky Loader.');
}
let api;
try {
    api = internalAPIConnection.connect(API_VERSION, manifest.name);
}
catch {
    api = internalAPIConnection.connect(1, manifest.name);
    console.warn(`[@decky/api] Requested API version ${API_VERSION} but the running loader only supports version 1. Some features may not work.`);
}
if (api._version != API_VERSION) {
    console.warn(`[@decky/api] Requested API version ${API_VERSION} but the running loader only supports version ${api._version}. Some features may not work.`);
}
const routerHook = api.routerHook;
const definePlugin = (fn) => {
    return (...args) => {
        return fn(...args);
    };
};

var DefaultContext = {
  color: undefined,
  size: undefined,
  className: undefined,
  style: undefined,
  attr: undefined
};
var IconContext = SP_REACT.createContext && /*#__PURE__*/SP_REACT.createContext(DefaultContext);

var _excluded = ["attr", "size", "title"];
function _objectWithoutProperties(e, t) { if (null == e) return {}; var o, r, i = _objectWithoutPropertiesLoose(e, t); if (Object.getOwnPropertySymbols) { var n = Object.getOwnPropertySymbols(e); for (r = 0; r < n.length; r++) o = n[r], -1 === t.indexOf(o) && {}.propertyIsEnumerable.call(e, o) && (i[o] = e[o]); } return i; }
function _objectWithoutPropertiesLoose(r, e) { if (null == r) return {}; var t = {}; for (var n in r) if ({}.hasOwnProperty.call(r, n)) { if (-1 !== e.indexOf(n)) continue; t[n] = r[n]; } return t; }
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function ownKeys(e, r) { var t = Object.keys(e); if (Object.getOwnPropertySymbols) { var o = Object.getOwnPropertySymbols(e); r && (o = o.filter(function (r) { return Object.getOwnPropertyDescriptor(e, r).enumerable; })), t.push.apply(t, o); } return t; }
function _objectSpread(e) { for (var r = 1; r < arguments.length; r++) { var t = null != arguments[r] ? arguments[r] : {}; r % 2 ? ownKeys(Object(t), true).forEach(function (r) { _defineProperty(e, r, t[r]); }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(t)) : ownKeys(Object(t)).forEach(function (r) { Object.defineProperty(e, r, Object.getOwnPropertyDescriptor(t, r)); }); } return e; }
function _defineProperty(e, r, t) { return (r = _toPropertyKey(r)) in e ? Object.defineProperty(e, r, { value: t, enumerable: true, configurable: true, writable: true }) : e[r] = t, e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == typeof i ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != typeof t || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r); if ("object" != typeof i) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }
function Tree2Element(tree) {
  return tree && tree.map((node, i) => /*#__PURE__*/SP_REACT.createElement(node.tag, _objectSpread({
    key: i
  }, node.attr), Tree2Element(node.child)));
}
function GenIcon(data) {
  return props => /*#__PURE__*/SP_REACT.createElement(IconBase, _extends({
    attr: _objectSpread({}, data.attr)
  }, props), Tree2Element(data.child));
}
function IconBase(props) {
  var elem = conf => {
    var attr = props.attr,
      size = props.size,
      title = props.title,
      svgProps = _objectWithoutProperties(props, _excluded);
    var computedSize = size || conf.size || "1em";
    var className;
    if (conf.className) className = conf.className;
    if (props.className) className = (className ? className + " " : "") + props.className;
    return /*#__PURE__*/SP_REACT.createElement("svg", _extends({
      stroke: "currentColor",
      fill: "currentColor",
      strokeWidth: "0"
    }, conf.attr, attr, svgProps, {
      className: className,
      style: _objectSpread(_objectSpread({
        color: props.color || conf.color
      }, conf.style), props.style),
      height: computedSize,
      width: computedSize,
      xmlns: "http://www.w3.org/2000/svg"
    }), title && /*#__PURE__*/SP_REACT.createElement("title", null, title), props.children);
  };
  return IconContext !== undefined ? /*#__PURE__*/SP_REACT.createElement(IconContext.Consumer, null, conf => elem(conf)) : elem(DefaultContext);
}

// THIS FILE IS AUTO GENERATED
function FaFolder (props) {
  return GenIcon({"attr":{"viewBox":"0 0 512 512"},"child":[{"tag":"path","attr":{"d":"M464 128H272l-64-64H48C21.49 64 0 85.49 0 112v288c0 26.51 21.49 48 48 48h416c26.51 0 48-21.49 48-48V176c0-26.51-21.49-48-48-48z"},"child":[]}]})(props);
}

// Pestañas de Steam que se mantienen, en este orden, antes de las colecciones.
// IDs posibles: GreatOnDeck, AllGames, Installed, Favorites, Collections, DesktopApps, Soundtracks
const PESTANAS_STEAM = [];
// Colecciones de Steam (por nombre exacto) que se muestran como pestaña, en este orden.
const COLECCIONES = ["Seba", "xxxx", "AAA", "Nintendo", "Terminados", "Apps"];

const log = (...a) => console.log("[Pestanas]", ...a);
// Cachés por componente original: así cada componente envuelto mantiene la misma
// identidad entre renders (React no remonta la biblioteca) y no se acumulan parches.
const cacheExterno = new WeakMap();
const cacheInterno = new WeakMap();
const cacheMemo = new WeakMap();
let Grilla;
function hooksReact() {
    const R = window.SP_REACT;
    return (R?.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED?.ReactCurrentDispatcher?.current ||
        Object.values(R?.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE ?? {}).find((p) => p?.useEffect));
}
function armarPestanas(tabs, deps) {
    const plantilla = tabs.find((t) => t?.id === "AllGames");
    if (!plantilla)
        return tabs;
    const filtro = deps.find((d) => typeof d?.Matches === "function");
    if (!filtro)
        return tabs;
    Grilla ?? (Grilla = DFL.findInReactTree(plantilla.content, (e) => e?.type && e.type.toString?.().includes("Library_FilteredByHeader"))?.type);
    if (!Grilla) {
        log("no encontré la grilla de juegos");
        return tabs;
    }
    const Ctx = plantilla.content?.type?._context;
    const [eSortBy, setSortBy, showSortingContextMenu] = deps;
    const deSteam = PESTANAS_STEAM.map((id) => tabs.find((t) => t?.id === id)).filter(Boolean);
    const propias = COLECCIONES.map((nombre) => {
        const col = collectionStore?.userCollections?.find((c) => c.displayName === nombre);
        if (!col)
            return null;
        const grilla = (SP_JSX.jsx(Grilla, { collection: col, eSortBy: eSortBy, setSortBy: setSortBy, showSortingContextMenu: showSortingContextMenu }));
        return {
            title: nombre,
            id: "pestanas-" + col.id,
            footer: plantilla.footer ?? {},
            content: Ctx ? SP_JSX.jsx(Ctx.Provider, { value: { label: nombre }, children: grilla }) : grilla,
            renderTabAddon: () => (SP_JSX.jsx("span", { className: DFL.gamepadTabbedPageClasses.TabCount, children: col.GetAppCountWithToolsFilter?.(filtro) ?? col.visibleApps?.length })),
        };
    }).filter(Boolean);
    const final = [...deSteam, ...propias];
    return final.length ? final : tabs;
}
// Componente de más adentro (memo): durante su render cambiamos useMemo para
// reemplazar la lista de pestañas que calcula Steam.
function envolverInterno(C) {
    let w = cacheInterno.get(C);
    if (w)
        return w;
    w = function (...args) {
        const hooks = hooksReact();
        if (!hooks?.useMemo)
            return C.apply(this, args);
        const real = hooks.useMemo;
        hooks.useMemo = (fn, deps) => real(() => {
            const orig = fn();
            const anidado = Array.isArray(orig) && Array.isArray(orig[0]);
            const tabs = anidado ? orig[0] : orig;
            if (!Array.isArray(tabs) || !tabs.some((t) => t?.id === "AllGames"))
                return orig;
            try {
                const nuevas = armarPestanas(tabs, deps ?? []);
                return anidado ? [nuevas, ...orig.slice(1)] : nuevas;
            }
            catch (e) {
                log("error armando pestañas", e);
                return orig;
            }
        }, deps);
        try {
            return C.apply(this, args);
        }
        finally {
            hooks.useMemo = real;
        }
    };
    cacheInterno.set(C, w);
    return w;
}
function envolverMemo(m) {
    let w = cacheMemo.get(m);
    if (w)
        return w;
    w = { ...m, type: envolverInterno(m.type) };
    cacheMemo.set(m, w);
    return w;
}
// Componente intermedio: devuelve el memo que tiene las pestañas.
function envolverExterno(B) {
    let w = cacheExterno.get(B);
    if (w)
        return w;
    w = function (...args) {
        const r = B.apply(this, args);
        if (r?.type && typeof r.type === "object" && typeof r.type.type === "function") {
            r.type = envolverMemo(r.type);
        }
        return r;
    };
    cacheExterno.set(B, w);
    return w;
}
const cacheRuta = new WeakMap();
function envolverRuta(A) {
    let w = cacheRuta.get(A);
    if (w)
        return w;
    w = function (...args) {
        const r = A.apply(this, args);
        if (r && typeof r.type === "function")
            r.type = envolverExterno(r.type);
        return r;
    };
    cacheRuta.set(A, w);
    return w;
}
const parcheRuta = (props) => {
    const hijo = props?.children;
    if (hijo && typeof hijo.type === "function")
        hijo.type = envolverRuta(hijo.type);
    return props;
};
var index = definePlugin(() => {
    routerHook.addPatch("/library", parcheRuta);
    log("cargado");
    return {
        name: "Tabs krarupOS",
        titleView: SP_JSX.jsx("div", { children: "Tabs krarupOS" }),
        content: (SP_JSX.jsxs("div", { style: { padding: "1em" }, children: ["Tabs: ", [...PESTANAS_STEAM, ...COLECCIONES].join(", ")] })),
        icon: SP_JSX.jsx(FaFolder, {}),
        onDismount() {
            routerHook.removePatch("/library", parcheRuta);
        },
    };
});

export { index as default };
//# sourceMappingURL=index.js.map
