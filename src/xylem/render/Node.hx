package xylem.render;

import xylem.IDomElement.IDomElementUntyped;
import xylem.IElement.IElementUntyped;
import xylem.Props.PropsUtility;
import xylem.render.context.LazyRenderContext;
import xylem.render.domeffect.IDomEffect;
import xylem.render.domeffect.IDomEffectProvider;
import xylem.render.domeffect.NodeEffectWalker;
import xylem.render.hooks.StatefulElementHooks;

// TODO: Make fields private. Need a better test access pattern.
/**
 * A Node encapsulates an Element and contains links to output/child nodes.
 * 
 * Properties:
 * - Element/Props may not change without triggering re-render from Node itself. Changes to these go through tryUpdate* methods.
 *   - TODO: Element change = new Node?
 * - State may change due to something external (e.g. a subscription). When this happens, the responsible hook must call update.
 */
class Node
{
    // The element for this Node
    public var element:IElementUntyped;

    // The output resulting from rendering the element + props. Called "child" in React.
    public var output:Node;

    // Nodes for child Elements coming from Props
    public var children:Array<Node> = new Array<Node>();

    // Contains the set of functions that can be called from within an Element
    public var hooks:StatefulElementHooks;

    // Used to register child nodes with the renderer
    private final lazyRenderer:Null<LazyRenderer<Dynamic>>;

    // The DOM-specific effect. No-op for Nodes with no IDomElement.
    public final effect:IDomEffect<Dynamic>;

    private final effectProvider:IDomEffectProvider<Dynamic>;

    private function new(element:IElementUntyped, effectProvider:IDomEffectProvider<Dynamic>, lazyRenderer:Null<LazyRenderer<Dynamic>>)
    {
        this.element = element;
        this.hooks = buildHooks(this);
        this.lazyRenderer = lazyRenderer;
        this.effect = effectProvider.buildEffect(new NodeEffectWalker<Dynamic>(this));
        this.effectProvider = effectProvider;
    }

    /**
     * Build a new Node with an optional parent Renderer. Render as a side-effect of building.
     * @param element The Element this Node renders.
     * @param effectProvider Provides DOM effects for a specific DOM implementation.
     * @param lazyRenderer (optional) The parent renderer.
     * @return Node The node.
     */
    public static function build(element:IElementUntyped, effectProvider:IDomEffectProvider<Dynamic>, lazyRenderer:Null<LazyRenderer<Dynamic>> = null):Node
    {
        var node = new Node(element, effectProvider, lazyRenderer);
        node.update(RenderMode.Mount);
        return node;
    }

    public function tryUpdateWithElement(pendingElement:IElementUntyped)
    {
        if (Type.getClass(pendingElement) == Type.getClass(element))
        {
            tryUpdateWithProps(pendingElement.props);
        }
        else
        {
            // Can't use memoized props if the element type has changed (TODO: should this just be a new Node?)
            if (lazyRenderer != null)
            {
                lazyRenderer.replaceNode(this, element, pendingElement);
            }

            element = pendingElement;
            externalUpdate(RenderMode.Mount);
        }
    }

    public function tryUpdateWithProps(pendingProps:Props)
    {
        if (!PropsUtility.shallowEquals(element.props, pendingProps))
        {
            var pendingElement = PropsUtility.withProps(element, pendingProps);
            if (lazyRenderer != null)
            {
                lazyRenderer.replaceNode(this, element, pendingElement);
            }

            element = pendingElement;
            externalUpdate(RenderMode.Mount);
        }
    }

    /**
     * Recurse through output and child Nodes until we reach IDomElements, then compose them recursively to build the complete output
     * tree. All reachable returned Elements should be IDomElements.
     *  
     * Should only be called in tests/cases where we need the full output Element tree.
     * @return IDomElementUntyped
     */
    public function compose():IDomElementUntyped
    {
        // Two cases:
        // - If this Node is not a DomElement, we need to keep recursing through the output.
        // - Otherwise, recurse through children and attach them to this DomElement to form the final output.
        if (!Std.is(element, IDomElement))
        {
            return output.compose();
        }
        else
        {
            var domElement:IDomElementUntyped = cast element;
            var props:Props = domElement.props;

            var outputChildren:Array<IElementUntyped> = children.map((childNode) -> cast(childNode.compose(), IElementUntyped));
            var outputProps = PropsUtility.cloneWithChildren(props, outputChildren);
            return PropsUtility.withProps(domElement, outputProps);
        }
    }

    public function dispose()
    {
        if (output != null)
        {
            output.dispose();
        }

        for (child in children)
        {
            child.dispose();
        }

        disposeShallow();
    }

    // Every external update also re-applies DomEffects. externalUpdate should not be called recursively.
    private function externalUpdate(mode:RenderMode)
    {
        update(mode);

        if (effect.attachedToDom())
        {
            effect.applyRoot();
        }
    }

    private function update(mode:RenderMode)
    {
        // Build/update the output Node if we haven't hit a DomElement yet
        if (!Std.is(element, IDomElement))
        {
            var renderContext = new LazyRenderContext(hooks, mode);
            var outputElement = cast element.renderShallow(renderContext);

            if (output == null)
            {
                output = buildChildOrOutput(outputElement);
            }
            else
            {
                output.tryUpdateWithElement(outputElement);
            }
        }
        else
        {
            // Recurse into children
            var domElement:IDomElementUntyped = cast element;

            // Extract props off the correctly-typed output
            var props:Props = domElement.props;

            // Get the original set of children from the props
            var childElements:Array<IElementUntyped> = PropsUtility.getChildren(props);

            // Dispose child Nodes that no longer have corresponding Elements
            while (children.length > childElements.length)
            {
                var child = children.pop();
                child.dispose();
            }

            for (i in 0...childElements.length)
            {
                var childElement:IElementUntyped = cast childElements[i];
                if (i < children.length)
                {
                    children[i].tryUpdateWithElement(childElement);
                }
                else
                {
                    children.push(buildChildOrOutput(childElement));
                }
            }
        }

        hooks.effectHookContainer.runEffectHooks();
    }

    private function buildChildOrOutput(inputElement:IElementUntyped):Node
    {
        if (lazyRenderer != null)
        {
            return lazyRenderer.buildOrGetNode(inputElement);
        }
        else
        {
            return Node.build(inputElement, effectProvider, lazyRenderer);
        }
    }

    private function disposeShallow()
    {
        if (lazyRenderer != null)
        {
            lazyRenderer.removeNode(element);
        }
        
        output = null;
        children = null;
        hooks.effectHookContainer.cleanupEffectHooks();
        hooks = null;

        effect.unapply();
    }

    /**
     * Build a new instance of hooks for the specified node. Give the hooks a callback to force update
     * @param node The node to build Hooks for.
     * @return Hooks Hooks that can force the node to update.
     */
    private static function buildHooks(node:Node):StatefulElementHooks
    {
        return new StatefulElementHooks(node.element, () -> node.externalUpdate(RenderMode.Update));
    }
}
