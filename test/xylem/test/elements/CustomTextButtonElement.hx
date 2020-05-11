package xylem.test.elements;

import xylem.elements.dom.FlowElement;
import xylem.elements.dom.TextElement;
import xylem.IElement;
import h2d.Flow.FlowAlign;
import hxmath.math.Vector2;

// TODO: Move this out of core library

@:structInit
class CustomTextButtonProps
{
    public final text:String;
    public final position:Vector2;
    public final textScale:Float;
    public final onClick:hxd.Event->Void;
}

class CustomTextButtonElement implements IElement<CustomTextButtonProps, Dynamic>
{
    public final props:CustomTextButtonProps;
    public final state:Dynamic = null;

    public function new(props:CustomTextButtonProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return new FlowElement({
            position: props.position,
            enableInteractive: true,
            interactive_onClick: props.onClick,
            horizontalAlign: FlowAlign.Middle,
            verticalAlign: FlowAlign.Middle,
            backgroundTileBuilder: () -> h2d.Tile.fromColor(0x444444,1,1, .5),
            borderHeight: 10,
            borderWidth: 10,
            children: [
                new TextElement({ text: props.text, scale: props.textScale })
            ]
        });
    }
}