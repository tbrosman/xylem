package xylem.render.domeffect;

import xylem.IElement.IElementUntyped;

class NodeEffectWalker<TContext> implements IEffectWalker<TContext>
{
    private final node:Node;

    public function new(node:Node)
    {
        this.node = node;
    }

    public function getElement():IElementUntyped
    {
        return node.element;
    }

    public function getOutputEffect():IDomEffect<TContext>
    {
        return cast node.output.effect;
    }

    public function getChildEffects():Array<IDomEffect<TContext>>
    {
        return node.children.map(child -> cast child.effect);
    }
}
