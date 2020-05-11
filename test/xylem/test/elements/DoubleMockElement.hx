package xylem.test.elements;

import xylem.IElement;

@:structInit
class DoubleMockProps
{
    public final name1:String;
    public final name2:String;
    public final children:Array<IElementUntyped>;
}

class DoubleMockElement implements IElement<DoubleMockProps, Dynamic>
{
    public final props:DoubleMockProps;
    public final state:Dynamic = null;

    public function new(props:DoubleMockProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return new MockElement({
            name: props.name1,
            children: [
                new MockElement({
                    name: props.name2,
                    children: props.children
                })
            ]
        });
    }
}