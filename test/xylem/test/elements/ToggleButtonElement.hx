package xylem.test.elements;

import hxmath.math.Vector2;
import hxd.Event;
import xylem.IElement;
import xylem.test.elements.CustomTextButtonElement;

@:structInit
class ToggleButtonProps
{
    public final name:String;
    public final position:Vector2;
}

class ToggleButtonElement implements IElement<ToggleButtonProps, { on:Bool }>
{
    public final props:ToggleButtonProps;
    public final state:{ on:Bool };

    public function new(props:ToggleButtonProps)
    {
        this.props = props;
        this.state = { on: false };
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        var onClick = (event:Event) -> {
            renderContext.setState({ on: !state.on });
        }

        return new CustomTextButtonElement({
            text: '${props.name}: ${state.on}',
            position: props.position,
            textScale: 10,
            onClick: onClick
        });
    }
}