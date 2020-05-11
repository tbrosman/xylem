package xylem.render.context;

import xylem.render.hooks.EffectHook;

/**
 * Does nothing.
 */
class NoopRenderContext implements IRenderContext
{
    public function new()
    {
    }

    public function useEffect(effect:EffectHook, dependencies:Array<Dynamic>):Void
    {
    }

    public function setState(partialState:Dynamic):Void
    {
    }
}