package xylem.test.elements;

import xylem.IElement;

@:structInit
class MultiplierProps
{
    public final name:String;
    public final count:Int;
}

@:structInit
class MultiplierState
{
    public final count:Int;
}

class MultiplierElement implements IElement<MultiplierProps, MultiplierState>
{
    public final props:MultiplierProps;
    public final state:MultiplierState;

    public function new(props:MultiplierProps)
    {
        this.props = props;
        this.state = { count: props.count };
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        var count = state.count;

        var outputChildren:Array<IElementUntyped> = [];

        for (i in 0...count)
        {
            outputChildren.push(
                new MockElement({
                    name: '${props.name}_${i}'
                })
            );
        }

        return new MockElement({
            name: props.name,
            children: outputChildren
        });
    }
}