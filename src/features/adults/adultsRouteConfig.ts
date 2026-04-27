export const adultsRouteConfig = {
  path: "/adults",
  modeKey: "adults",
  label: "Adults",
  defaultSessionMode: "QuickFocus",
  defaultCertifiedId: "A-AC01-A1-P01",
  sessionModes: ["QuickFocus", "Standard", "Deep", "Recovery"]
};

export const adultsNavigationEntry = {
  path: adultsRouteConfig.path,
  modeKey: adultsRouteConfig.modeKey,
  label: adultsRouteConfig.label
};
