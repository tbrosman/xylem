package xylem;

import xylem.diagnostics.Assert;
import xylem.IElement.IElementUntyped;

/**
 * Used to annotate types that should be considered Props.
 */
typedef Props = Dynamic;

/**
 * Implemented by Props. Children is empty for terminal Elements.
 */
class PropsUtility
{
    public static function withProps<TElement:IElementUntyped>(element:TElement, props:Props):TElement
    {
        var elementClass:Class<TElement> = Type.getClass(element);
        var elementClone = Type.createInstance(elementClass, [props]);
        return elementClone;
    }

    /**
     * The children of an Element. Empty for terminal Elements.
     * @return Array<IElementUntyped> The children.
     */
    public static function getChildren(props:Props):Array<IElementUntyped>
    {
        var children:Array<IElementUntyped> = Reflect.field(props, "children");
        return children != null
            ? children
            : [];
    }

    public static function shallowEquals(propsA:Dynamic, propsB:Dynamic):Bool
    {
        var fieldsA = Reflect.fields(propsA);
        var fieldsB = Reflect.fields(propsB);

        if (fieldsA.length != fieldsB.length)
        {
            return false;
        }

        fieldsA.sort(sortingFunction);
        fieldsB.sort(sortingFunction);

        for (i in 0...fieldsA.length)
        {
            if (fieldsA[i] != fieldsB[i])
            {
                return false;
            }
        }

        for (i in 0...fieldsA.length)
        {
            if (Reflect.field(propsA, fieldsA[i]) != Reflect.field(propsB, fieldsB[i]))
            {
                return false;
            }
        }

        return true;
    }

    public static function cloneWithChildren<TProps:Props>(inputProps:TProps, newChildren:Array<IElementUntyped>):TProps
    {
        // Lazy clone: if no children, do nothing
        // TODO: Come up with a better way to reference children. This is assumes the children property is named "children."
        if (!Reflect.hasField(inputProps, "children"))
        {
            Assert.assert(newChildren.length == 0);
            return inputProps;
        }

        var fieldNames = Reflect.fields(inputProps);
        var propsClass:Class<TProps> = Type.getClass(inputProps);
        var outputProps:TProps = cast Type.createEmptyInstance(propsClass);
        for (fieldName in fieldNames)
        {
            // Not sure why, but sometimes empty strings show up in the Reflect.fields output.
            if (fieldName != "")
            {
                Reflect.setField(outputProps, fieldName, Reflect.field(inputProps, fieldName));
            }
        }

        Reflect.setField(outputProps, "children", newChildren);
        return outputProps;
    }

    private static function sortingFunction(a:String, b:String):Int
    {
        if (a < b)
        {
            return -1;
        }
        else if (a > b)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
}