package xylem.render.context;

import xylem.render.hooks.EffectHook;
import xylem.render.hooks.StatefulElementHooks;

/**
 * Allows a component to set state and register effect hooks.
 */
class LazyRenderContext implements IRenderContext
{
    private final hooks:StatefulElementHooks;
    private var effectHookNumber:Int;
    private final mode:RenderMode;

    public function new(hooks:StatefulElementHooks, mode:RenderMode)
    {
        this.hooks = hooks;
        this.mode = mode;
    }

    public function useEffect(effect:EffectHook, dependencies:Array<Dynamic>):Void
    {
        this.hooks.effectHookContainer.addEffectHook(this.mode, effectHookNumber, effect, dependencies);
        effectHookNumber++;
    }

    public function setState(partialState:Dynamic):Void
    {
        this.hooks.setState(partialState);
    }
}