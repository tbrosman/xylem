package xylem.test.elements;

import xylem.IElement;

@:structInit
class StateSetterProps
{
    public final name:String;
    public final nameLater:String;
}

typedef StateSetterState =
{
    var name:String;
}

class StateSetterElement implements IElement<StateSetterProps, StateSetterState>
{
    public final props:StateSetterProps;
    public final state:StateSetterState = { name: null };

    public function new(props:StateSetterProps)
    {
        this.props = props;
        state.name = props.name;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        renderContext.useEffect(() -> {
            renderContext.setState({ name: props.nameLater });

            // No cleanup needed
            return null;
        }, []);

        return new MockDomElement({ name: state.name });
    }
}