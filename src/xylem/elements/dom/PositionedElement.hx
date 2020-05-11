package xylem.elements.dom;

import xylem.IElement.IElementUntyped;
import h2d.Object;
import hxmath.math.Vector2;
import xylem.heaps.IHeapsElement;

@:structInit
class PositionedProps
{
    public final position:Vector2;
    public final children:Array<IElementUntyped> = [];
}

class PositionedElement implements IHeapsElement<PositionedProps, Dynamic>
{
    public final props:PositionedProps;
    public final state:Dynamic = null;

    public function new(props:PositionedProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return this;
    }

    public function applyShallow(parent:Object, existing:Object):Object
    {
        var obj:Object = new Object(parent);
        obj.x = props.position.x;
        obj.y = props.position.y;
        return obj;
    }
}
