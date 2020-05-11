package xylem.render.hooks;

class PureFunctionHooks
{
    public final effectHookContainer:EffectHookContainer = new EffectHookContainer();
    private final stateValues:Map<String, Dynamic> = new Map<String, Dynamic>();
    private final nodeUpdate:()->Void;

    public function new(nodeUpdate:()->Void)
    {
        this.nodeUpdate = nodeUpdate;
    }

    public function useState<T>(name:String, defaultValue:T):StateHook<T>
    {
        setInitialState(name, defaultValue);
        var hook:StateHook<T> =
        {
            state: () -> getState(name),
            setState: (value:T) -> setState(name, value)
        }

        return hook;
    }

    public function getState<T>(name:String):T
    {
        return stateValues.get(name);
    }

    public function setInitialState<T>(name:String, value:T):Void
    {
        // Only set the state if this is the first time writing the value
        if (!stateValues.exists(name))
        {
            stateValues.set(name, value);
        }
    }

    public function setState<T>(name:String, value:T):Void
    {
        // Do nothing if the value didn't change
        if (stateValues.get(name) != value)
        {
            stateValues.set(name, value);
            nodeUpdate();
        }
    }
}