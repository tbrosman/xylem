package xylem;

/**
 * Elements work similar to React Elements.
 * - Each Element is a declarative tree node. It does not describe how the render works, just the properties for its level.
 * - Elements are immutable. If an Element needs to change, it is replaced in the tree.
 */
interface IElement<TProps:Props, TState>
{
    final props:TProps;

    // TODO: Find a way to make this private but give Hooks access.
    final state:TState;

    /**
     * Render one level of the tree. Does not expand child elements.
     * Returns the same Element if there is nothing to render (e.g. this is a DomElement).
     * @return IElement<Dynamic> The expanded tree.
     */
    function renderShallow(renderContext:IRenderContext):IElementUntyped;
}

/**
 * An untyped version of Element. The only thing it can do is render. This flavor of Element is used internally and not meant to be
 * extended directly.
 */
typedef IElementUntyped = IElement<Dynamic, Dynamic>;
