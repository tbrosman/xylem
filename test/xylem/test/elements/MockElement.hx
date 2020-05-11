package xylem.test.elements;

import xylem.IElement;

@:structInit
class MockProps
{
    public final name:String;
    public final children:Array<IElementUntyped> = [];
}

class MockElement implements IElement<MockProps, Dynamic>
{
    public final props:MockProps;
    public final state:Dynamic = null;

    public function new(props:MockProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return new MockDomElement({ name: props.name, children: props.children });
    }
}