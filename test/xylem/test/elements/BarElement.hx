package xylem.test.elements;

import xylem.elements.dom.TextElement;
import xylem.elements.dom.PositionedElement;
import xylem.elements.dom.RectElement;
import xylem.IElement;
import hxmath.geom.Rect;
import hxmath.math.Vector2;

// TODO: Move this out of core library

@:structInit
class BarProps
{
    public final bounds:Rect;
    public final current:Float;
    public final max:Float;
}

class BarElement implements IElement<BarProps, Dynamic>
{
    public final props:BarProps;
    public final state:Dynamic = null;

    public function new(props:BarProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return new PositionedElement({
            position: new Vector2(props.bounds.x, props.bounds.y),
            children: [
                new RectElement({
                    fill: 0x000000,
                    rect: new Rect(0, 0, props.bounds.width, props.bounds.height)
                }),
                new RectElement({
                    fill: 0xFFFFFF,
                    rect: new Rect(
                        0,
                        0,
                        (props.current / props.max) * props.bounds.width,
                        props.bounds.height)
                }),
                new TextElement({
                    scale: 2,
                    text: '${props.current}/${props.max}',
                    position: new Vector2(props.bounds.width + 5, 0.0)
                })
            ]
        });
    }
}