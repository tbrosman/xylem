package xylem.elements.dom;

import xylem.IElement;
import h2d.Graphics;
import h2d.Object;
import xylem.heaps.IHeapsElement;
import hxmath.geom.Rect;

@:structInit
class RectProps
{
    public final fill:Int;
    public final rect:Rect;
}

class RectElement implements IHeapsElement<RectProps, Dynamic>
{
    public final props:RectProps;
    public final state:Dynamic = null;

    public function new(props:RectProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return this;
    }

    public function applyShallow(parent:Object, existing:Object):Object
    {
        var graphics:Graphics;
        if (existing == null)
        {
            graphics = new Graphics(parent);
        }
        else
        {
            graphics = cast existing;
        }

        updateExistingGraphics(graphics);

        return graphics;
    }

    private function updateExistingGraphics(graphics:Graphics)
    {
        graphics.clear();
        graphics.beginFill(props.fill);
        graphics.drawRect(props.rect.x, props.rect.y, props.rect.width, props.rect.height);
        graphics.endFill();
    }
}