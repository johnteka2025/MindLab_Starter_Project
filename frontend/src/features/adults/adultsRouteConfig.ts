import { adultsSessionModes, defaultAdultsSessionMode } from "./adultsSessionModes";

export const adultsRouteConfig = {
  path: "/adults",
  modeKey: "adults",
  label: "Adults",
  defaultSessionMode: defaultAdultsSessionMode,
  defaultCertifiedId: "A-AC01-A1-P01",
  sessionModes: adultsSessionModes.map((mode) => mode.id)
};

export const adultsNavigationEntry = {
  path: adultsRouteConfig.path,
  modeKey: adultsRouteConfig.modeKey,
  label: adultsRouteConfig.label
};
