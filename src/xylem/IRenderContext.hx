package xylem;

import xylem.render.hooks.EffectHook;

/**
 * Available during render. Allows components to register hooks/change state in hooks.
 */
interface IRenderContext
{
    /**
     * Add a callback that performs a side effect if and only if it has never run or the dependencies change.
     * @param hook The hook to add.
     * @param dependencies The dependencies to watch.
     */
    function useEffect(effect:EffectHook, dependencies:Array<Dynamic>):Void;

    /**
     * Set one of the fields on the Element's state. Can only be called in an effect hook.
     * Takes an object of the form `{ field: value, ... }` where each field must exist on the Element's state object.
     * @param partialState An object containing the state values to update.
     */
    function setState(partialState:Dynamic):Void;
}