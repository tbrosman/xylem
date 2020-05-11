package xylem.render.domeffect;

import xylem.IElement.IElementUntyped;

/**
 * Provides a Renderer implementation-independent layer for accessing the DomEffect graph. DomEffect drives traversal as well as
 * applying the effects themselves.
 */
interface IEffectWalker<TContext>
{
    /**
     * Get the current Element.
     * @return IElementUntyped The element.
     */
    function getElement():IElementUntyped;

    /**
     * If there is an output effect, return it. May return null.
     * @return IDomEffect<TContext> The output effect.
     */
    function getOutputEffect():IDomEffect<TContext>;

    /**
     * If there are output effects for child elements/nodes, return them. May return an empty array.
     * @return Array<IDomEffect<TContext>> The child output effects.
     */
    function getChildEffects():Array<IDomEffect<TContext>>;
}
