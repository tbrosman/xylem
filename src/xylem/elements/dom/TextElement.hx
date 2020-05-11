package xylem.elements.dom;

import hxmath.math.Vector2;
import xylem.IElement;
import h2d.Object;
import h2d.Text;
import xylem.heaps.IHeapsElement;

@:structInit
class TextProps
{
    public final text:String;
    public final textColor:Int = 0xFFFFFF;
    public final position:Vector2 = new Vector2(0, 0);
    public final scale:Float;
}

class TextElement implements IHeapsElement<TextProps, Dynamic>
{
    public final props:TextProps;
    public final state:Dynamic = null;

    public function new(props:TextProps)
    {
        this.props = props;
    }

    public function renderShallow(renderContext:IRenderContext):IElementUntyped
    {
        return this;
    }

    public function applyShallow(parent:Object, existing:Object):Object
    {
        if (tryUpdateExistingObject(existing))
        {
            return existing;
        }

        var textBox = new Text(hxd.res.DefaultFont.get(), parent);
        textBox.text = props.text;
        textBox.scaleX = props.scale;
        textBox.scaleY = props.scale;
        textBox.setPosition(props.position.x, props.position.y);
        textBox.textColor = props.textColor;
        return textBox;
    }

    private function tryUpdateExistingObject(existing:Object)
    {
        if (existing != null)
        {
            // Update in place if possible
            if (Std.is(existing, Text))
            {
                var existingText:Text = cast existing;

                if (existingText.scaleX != props.scale || existingText.scaleY != props.scale)
                {
                    existingText.scaleX = props.scale;
                    existingText.scaleY = props.scale;
                }
                
                if (existingText.text != props.text)
                {
                    existingText.text = props.text;
                }

                existingText.setPosition(props.position.x, props.position.y);
                existingText.textColor = props.textColor;

                return true;
            }
        }

        return false;
    }
}