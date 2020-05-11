package xylem.test.elements;

import xylem.diagnostics.Assert;
import xylem.IElement;

typedef SubscriptionCallback = (newState:String)->Void;

class SubscriptionBus
{
    public var hasSubscriber(get, never):Bool;
    private var callback:SubscriptionCallback;

    public function new()
    {
    }

    public function subscribe(callback:SubscriptionCallback):Void
    {
        Assert.assert(this.callback == null);
        this.callback = callback;
    }
    public function unsubscribe(callback:SubscriptionCallback):Void
    {
        Assert.assert(this.callback == callback);
        this.callback = null;
    }

    public function set(newState:String):Void
    {
        if (callback != null)
        {
            callback(newState);
        }
    }

    private function get_hasSubscriber():Bool
    {
        return callback != null;
    }
}

@:structInit
class SubscribingProps
{
    public final name:String;
    public final subscriptionBus:SubscriptionBus;
}

typedef SubscribingState =
{
    var name:String;
}

class SubscribingElement implements IElement<SubscribingProps, SubscribingState>
{
    public final props:SubscribingProps;
    public final state:SubscribingState = { name: null };

    public function new(props:SubscribingProps)
    {
        this.props = props;
        state.name = props.name;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        renderContext.useEffect(() -> {
            var callback:SubscriptionCallback = (name) ->
                renderContext.setState({ name: name });
            props.subscriptionBus.subscribe(callback);
            return () -> props.subscriptionBus.unsubscribe(callback);
        }, []);

        return new MockDomElement({ name: state.name });
    }
}