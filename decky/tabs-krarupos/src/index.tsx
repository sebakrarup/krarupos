import { definePlugin, routerHook } from "@decky/api";
import { findInReactTree, gamepadTabbedPageClasses } from "@decky/ui";
import { FaFolder } from "react-icons/fa";
import { PESTANAS_STEAM, COLECCIONES } from "./pestanas";

declare const collectionStore: any;

const log = (...a: any[]) => console.log("[Pestanas]", ...a);

// Cachés por componente original: así cada componente envuelto mantiene la misma
// identidad entre renders (React no remonta la biblioteca) y no se acumulan parches.
const cacheExterno = new WeakMap<Function, Function>();
const cacheInterno = new WeakMap<Function, Function>();
const cacheMemo = new WeakMap<object, object>();
let Grilla: any;

function hooksReact(): any {
  const R: any = (window as any).SP_REACT;
  return (
    R?.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED?.ReactCurrentDispatcher?.current ||
    Object.values(R?.__CLIENT_INTERNALS_DO_NOT_USE_OR_WARN_USERS_THEY_CANNOT_UPGRADE ?? {}).find(
      (p: any) => p?.useEffect
    )
  );
}

function armarPestanas(tabs: any[], deps: any[]): any[] {
  const plantilla = tabs.find((t) => t?.id === "AllGames");
  if (!plantilla) return tabs;
  const filtro = deps.find((d: any) => typeof d?.Matches === "function");
  if (!filtro) return tabs;
  Grilla ??= findInReactTree(
    plantilla.content,
    (e: any) => e?.type && e.type.toString?.().includes("Library_FilteredByHeader")
  )?.type;
  if (!Grilla) {
    log("no encontré la grilla de juegos");
    return tabs;
  }
  const Ctx = (plantilla.content?.type as any)?._context;
  const [eSortBy, setSortBy, showSortingContextMenu] = deps;

  const deSteam = PESTANAS_STEAM.map((id) => tabs.find((t) => t?.id === id)).filter(Boolean);
  const propias = COLECCIONES.map((nombre) => {
    const col = collectionStore?.userCollections?.find((c: any) => c.displayName === nombre);
    if (!col) return null;
    const grilla = (
      <Grilla
        collection={col}
        eSortBy={eSortBy}
        setSortBy={setSortBy}
        showSortingContextMenu={showSortingContextMenu}
      />
    );
    return {
      title: nombre,
      id: "pestanas-" + col.id,
      footer: plantilla.footer ?? {},
      content: Ctx ? <Ctx.Provider value={{ label: nombre }}>{grilla}</Ctx.Provider> : grilla,
      renderTabAddon: () => (
        <span className={gamepadTabbedPageClasses.TabCount}>
          {col.GetAppCountWithToolsFilter?.(filtro) ?? col.visibleApps?.length}
        </span>
      ),
    };
  }).filter(Boolean);

  const final = [...deSteam, ...propias];
  return final.length ? final : tabs;
}

// Componente de más adentro (memo): durante su render cambiamos useMemo para
// reemplazar la lista de pestañas que calcula Steam.
function envolverInterno(C: Function): Function {
  let w = cacheInterno.get(C);
  if (w) return w;
  w = function (this: any, ...args: any[]) {
    const hooks = hooksReact();
    if (!hooks?.useMemo) return C.apply(this, args);
    const real = hooks.useMemo;
    hooks.useMemo = (fn: () => any, deps: any[]) =>
      real(() => {
        const orig = fn();
        const anidado = Array.isArray(orig) && Array.isArray(orig[0]);
        const tabs = anidado ? orig[0] : orig;
        if (!Array.isArray(tabs) || !tabs.some((t: any) => t?.id === "AllGames")) return orig;
        try {
          const nuevas = armarPestanas(tabs, deps ?? []);
          return anidado ? [nuevas, ...orig.slice(1)] : nuevas;
        } catch (e) {
          log("error armando pestañas", e);
          return orig;
        }
      }, deps);
    try {
      return C.apply(this, args);
    } finally {
      hooks.useMemo = real;
    }
  };
  cacheInterno.set(C, w);
  return w;
}

function envolverMemo(m: any): any {
  let w: any = cacheMemo.get(m);
  if (w) return w;
  w = { ...m, type: envolverInterno(m.type) };
  cacheMemo.set(m, w);
  return w;
}

// Componente intermedio: devuelve el memo que tiene las pestañas.
function envolverExterno(B: Function): Function {
  let w = cacheExterno.get(B);
  if (w) return w;
  w = function (this: any, ...args: any[]) {
    const r: any = B.apply(this, args);
    if (r?.type && typeof r.type === "object" && typeof r.type.type === "function") {
      r.type = envolverMemo(r.type);
    }
    return r;
  };
  cacheExterno.set(B, w);
  return w;
}

const cacheRuta = new WeakMap<Function, Function>();
function envolverRuta(A: Function): Function {
  let w = cacheRuta.get(A);
  if (w) return w;
  w = function (this: any, ...args: any[]) {
    const r: any = A.apply(this, args);
    if (r && typeof r.type === "function") r.type = envolverExterno(r.type);
    return r;
  };
  cacheRuta.set(A, w);
  return w;
}

const parcheRuta = (props: any) => {
  const hijo = props?.children;
  if (hijo && typeof hijo.type === "function") hijo.type = envolverRuta(hijo.type);
  return props;
};

export default definePlugin(() => {
  routerHook.addPatch("/library", parcheRuta);
  log("cargado");
  return {
    name: "Tabs krarupOS",
    titleView: <div>Tabs krarupOS</div>,
    content: (
      <div style={{ padding: "1em" }}>
        Tabs: {[...PESTANAS_STEAM, ...COLECCIONES].join(", ")}
      </div>
    ),
    icon: <FaFolder />,
    onDismount() {
      routerHook.removePatch("/library", parcheRuta);
    },
  };
});
