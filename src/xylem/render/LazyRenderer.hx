package xylem.render;

import xylem.diagnostics.Assert;
import xylem.IDomElement.IDomElementUntyped;
import xylem.IElement.IElementUntyped;
import xylem.Props.PropsUtility;
import xylem.render.domeffect.IDomEffect;
import xylem.render.domeffect.IDomEffectProvider;

/**
 * Lazily renders Elements using Nodes.
 * 
 * Caching Behavior
 * 
 * This code uses a cache model that only uses a portion of the "full" cache key to index results. In a perfect world (infinite
 * memory), your cache key would contain everything needed to re-construct your output. This is costly when there are potentially
 * many values and only a subset of them are used (e.g. a cache for an Element containing a number that is incremented repeatedly).
 * As a trade-off we make some subset of the "true cache key" into a lookup key.
 * 
 * Looking up existing Nodes requires two steps:
 * - Find the map entry from a subset of the "true cache key."
 * - Check to see if the existing entry matches the remainder of the full cache key.
 * 
 * The result is you store fewer elements in your cache, but get can't a cache-hit with just a Map lookup. Note that in general,
 * how much of your "true key" you put in your lookup key is a matter of tuning. This cache's policy was designed with the
 * following assumptions:
 * 
 * - Few Nodes will be stateful
 * - In the cases where we do have a stateful node, it is likely cheaper to simply re-build the node than to keep all possible (or N
 * previous) state-versions.
 */
class LazyRenderer<TContext> implements IRenderer<TContext>
{
    private final effectProvider:IDomEffectProvider<TContext>;
    private final elementToNode:Map<IElementUntyped, Node> = new Map<IElementUntyped, Node>();

    public function new(effectProvider:IDomEffectProvider<TContext>)
    {
        this.effectProvider = effectProvider;
    }

    public function render(element:IElementUntyped):IDomElementUntyped
    {
        var node = buildOrGetNode(element);
        return node.compose();
    }

    public function apply(rootNode:Node, context:TContext):IDomEffect<TContext>
    {
        rootNode.effect.apply(context);
        return cast rootNode.effect;
    }

    public function renderAndApply(element:IElementUntyped, context:TContext):IDomEffect<TContext>
    {
        var node = buildOrGetNode(element);
        return apply(node, context);
    }

    /**
     * Build a new Node or get an existing one.
     * 
     * @param element The Element to look up/build a Node for.
     * @return Node The Node for this Element.
     */
    public function buildOrGetNode(element:IElementUntyped):Node
    {
        var node = tryGetNode(element);

        if (node == null)
        {
            // Either no existing node in the cache or node was insufficient, so build a new one
            node = Node.build(element, effectProvider, this);
            elementToNode[element] = node;
        }

        return node;
    }

    public function replaceNode(node:Node, oldElement:IElementUntyped, newElement:IElementUntyped):Void
    {
        Assert.assert(elementToNode[oldElement] == node);
        elementToNode[newElement] = node;
        elementToNode.remove(oldElement);
    }

    public function tryGetNode(element:IElementUntyped):Node
    {
        var node = elementToNode[element];
        if (node != null)
        {
            var isSufficient = PropsUtility.shallowEquals(element.state, node.element.state);
            if (isSufficient)
            {
                return node;
            }
        }

        return null;
    }

    public function removeNode(element:IElementUntyped):Void
    {
        Assert.assert(elementToNode.exists(element));
        elementToNode.remove(element);
    }

    public function getNodeCount():Int
    {
        return Lambda.count(elementToNode);
    }
}