package xylem.render.hooks;

import xylem.diagnostics.Assert;
import xylem.IElement.IElementUntyped;

class StatefulElementHooks
{
    public final effectHookContainer:EffectHookContainer = new EffectHookContainer();
    private final element:IElementUntyped;
    private final nodeUpdate:()->Void;

    public function new(element:IElementUntyped, nodeUpdate:()->Void)
    {
        this.element = element;
        this.nodeUpdate = nodeUpdate;
    }

    // TODO: Make this API safer
    public function setState(partialState:Dynamic):Void
    {
        var shouldUpdate = false;

        for (fieldName in Reflect.fields(partialState))
        {
            var newValue = Reflect.field(partialState, fieldName);

            // TODO: Relax this requirement and support typedefs?
            Assert.assert(Reflect.hasField(element.state, fieldName));

            // Do nothing if the value didn't change
            if (Reflect.field(element.state, fieldName) != newValue)
            {
                Reflect.setField(element.state, fieldName, newValue);
                shouldUpdate = true;
            }
        }

        if (shouldUpdate)
        {
            nodeUpdate();
        }
    }
}