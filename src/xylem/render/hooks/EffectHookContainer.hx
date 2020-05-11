package xylem.render.hooks;

import xylem.diagnostics.Assert;
import xylem.render.hooks.EffectHook;

typedef EffectEntry =
{
    var hook:EffectHook;
    var dependencies:Array<Dynamic>;
    var isDirty:Bool;
    var ?cleanup:EffectHookCleanup;
}

class EffectHookContainer
{
    private final effects:Array<EffectEntry> = new Array<EffectEntry>();

    public function new()
    {
    }

    /**
     * Add a callback that performs a side effect if and only if it has never run or the dependencies change.
     * @param hook The hook to add.
     * @param dependencies The dependencies to watch.
     */
    public function addEffectHook(mode:RenderMode, effectHookIndex:Int, hook:EffectHook, dependencies:Array<Dynamic>):Void
    {
        if (mode == RenderMode.Update)
        {
            Assert.assert(effectHookIndex < effects.length);
        }

        var existingEffect = effects[effectHookIndex];

        if (existingEffect != null)
        {
            var isDirty = !shallowEquals(existingEffect.dependencies, dependencies);
            existingEffect.isDirty = isDirty;
            existingEffect.dependencies = dependencies;

            // Replace the hook. We might have new captured variables.
            existingEffect.hook = hook;
        }
        else
        {
            var entry:EffectEntry = { hook: hook, dependencies: dependencies, isDirty: true };
            effects[effectHookIndex] = entry;
        }
    }
    
    public function runEffectHooks():Void
    {
        for (effect in effects)
        {
            if (effect.isDirty)
            {
                // Mark as not dirty in case we recurse through the same codepath.
                effect.isDirty = false;

                // Run the old cleanup if it exists
                if (effect.cleanup != null)
                {
                    effect.cleanup();
                }

                // Run the hook, update the cleanup method
                var cleanup:EffectHookCleanup = effect.hook();
                effect.cleanup = cleanup;
            }
        }
    }

    public function cleanupEffectHooks():Void
    {
        for (effect in effects)
        {
            effect.cleanup();
            effect.cleanup = null;
        }
    }

    // TODO: Combine with the reflective shallowEquals on PropsUtility
    private static function shallowEquals(a:Array<Dynamic>, b:Array<Dynamic>):Bool
    {
        if (a.length != b.length)
        {
            return false;
        }

        for (i in 0...a.length)
        {
            if (a[i] != b[i])
            {
                return false;
            }
        }

        return true;
    }
}