package xylem.test.elements;

import xylem.IDomElement;
import xylem.IElement;
import h2d.Object;
import xylem.heaps.IHeapsElement;

@:structInit
class MockDomProps
{
    public final name:String;
    public final children:Array<IElementUntyped> = [];
}

class MockDomElement implements IHeapsElement<MockDomProps, Dynamic>
{
    public final props:MockDomProps;
    public final state:Dynamic = null;

    public function new(props:MockDomProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return this;
    }

    public function applyShallow(parent:Object, existing:Object):Object
    {
        var object:Object = new Object(parent);
        object.name = props.name;
        return object;
    }
}