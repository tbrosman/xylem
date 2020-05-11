package xylem.render.domeffect;

/**
 * Allows consumers to build DOM effects without knowing the details of the implementation. In the case of Renderer internals, the
 * context type is ignored (specified as Dynamic) so that it is completely agnostic to the DOM type as well.
 */
interface IDomEffectProvider<TContext>
{
    /**
     * Build a DOM effect.
     * @param effectWalker Provides access to the underlying Element/Node structure. 
     * @return IDomEffect<TContext> The DOM effect.
     */
    function buildEffect(effectWalker:IEffectWalker<TContext>):IDomEffect<TContext>;
}