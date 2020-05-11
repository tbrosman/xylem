package xylem.render.domeffect;

import xylem.diagnostics.Assert;
import xylem.IDomElement.IDomElementUntyped;
import xylem.IElement.IElementUntyped;
import xylem.Props.PropsUtility;

class SimpleEffectWalker<TContext> implements IEffectWalker<TContext>
{
    private final domElement:IDomElementUntyped;
    private final effectProvider:IDomEffectProvider<TContext>;

    public function new(domElement:IDomElementUntyped, effectProvider:IDomEffectProvider<TContext>)
    {
        this.domElement = domElement;
        this.effectProvider = effectProvider;
    }

    public function getElement():IElementUntyped
    {
        return domElement;
    }

    public function getOutputEffect():IDomEffect<TContext>
    {
        return null;
    }

    public function getChildEffects():Array<IDomEffect<TContext>>
    {
        var childEffects = new Array<IDomEffect<TContext>>();
        for (childElement in PropsUtility.getChildren(domElement.props))
        {
            Assert.assert(Std.is(childElement, IDomElementUntyped), "Expected flat tree of DomElements");
            var childEffectWalker = new SimpleEffectWalker(cast childElement, effectProvider);
            var childEffect = effectProvider.buildEffect(childEffectWalker);
            childEffects.push(childEffect);
        }

        return childEffects;
    }
}
