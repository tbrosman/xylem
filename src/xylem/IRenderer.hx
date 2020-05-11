package xylem;

import xylem.render.domeffect.IDomEffect;
import xylem.IDomElement.IDomElementUntyped;
import xylem.IElement.IElementUntyped;

/**
 * Renders a tree of Elements into DomElements.
 */
interface IRenderer<TContext>
{
    /**
     * Take the props and render a DomElement tree.
     * @return IDomElement
     */
    function render(element:IElementUntyped):IDomElementUntyped;

    /**
     * Render an element and apply it to a DOM tree.
     * @param element The Element to render.
     * @param context The DOM context matching the IDomEffectProvider used by the Renderer.
     * @return IDomEffect<TContext> The root effect. Can be cleaned up outside of the Renderer.
     */
    function renderAndApply(element:IElementUntyped, context:TContext):IDomEffect<TContext>;
}
