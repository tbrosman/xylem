package xylem.render.hooks;

typedef EffectHookCleanup = Null<() -> Void>;
typedef EffectHook = () -> EffectHookCleanup;