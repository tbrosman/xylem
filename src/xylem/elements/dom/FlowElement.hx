package xylem.elements.dom;

import xylem.IDomElement;
import xylem.IElement.IElementUntyped;
import h2d.Flow;
import h2d.Object;
import hxmath.math.Vector2;
import xylem.heaps.IHeapsElement;


@:structInit
class FlowProps
{
    public final position:Vector2;
    public final enableInteractive:Bool = false;
    public final interactive_onClick:hxd.Event->Void = null;
    public final horizontalAlign:Null<FlowAlign> = null;
    public final verticalAlign:Null<FlowAlign> = null;
    public final backgroundTileBuilder:Builder<h2d.Tile> = null;
    public final borderWidth:Int = 0;
    public final borderHeight:Int = 0;
    public final children:Array<IElementUntyped> = [];
}

class FlowElement implements IHeapsElement<FlowProps, Dynamic>
{
    public final props:FlowProps;
    public final state:Dynamic = null;

    public function new(props:FlowProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return this;
    }

    public function applyShallow(parent:Object, existing:Object):Object
    {
        var flow:Flow = new Flow(parent);

        flow.x = props.position.x;
        flow.y = props.position.y;

        if (props.enableInteractive)
        {
            flow.enableInteractive = props.enableInteractive;
            flow.interactive.onClick = props.interactive_onClick;
        }
        
        flow.horizontalAlign = props.horizontalAlign;
        flow.verticalAlign = props.verticalAlign;

        if (props.backgroundTileBuilder != null)
        {
            flow.backgroundTile = props.backgroundTileBuilder();
        }
        
        flow.borderHeight = props.borderHeight;
        flow.borderWidth = props.borderWidth;
        return flow;
    }
}
