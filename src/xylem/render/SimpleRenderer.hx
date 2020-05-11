package xylem.render;

import xylem.diagnostics.Assert;
import xylem.IDomElement.IDomElementUntyped;
import xylem.IElement.IElementUntyped;
import xylem.IRenderer;
import xylem.Props.PropsUtility;
import xylem.render.context.NoopRenderContext;
import xylem.render.domeffect.IDomEffect;
import xylem.render.domeffect.IDomEffectProvider;
import xylem.render.domeffect.SimpleEffectWalker;

class SimpleRenderer<TContext> implements IRenderer<TContext>
{
    private final renderContext:NoopRenderContext = new NoopRenderContext();
    private final effectProvider:IDomEffectProvider<TContext>;

    public function new(effectProvider:IDomEffectProvider<TContext>)
    {
        this.effectProvider = effectProvider;
    }

    public function render<TProps:Props>(element:IElementUntyped):IDomElementUntyped
    {
        // Render the top-level Elements element first. Then render Elements below it.
        // Example: say we have <ButtonWithTextAndIcon/> as a starting point.
        //
        // 1. render(<ButtonWithTextAndIcon/>)
        //
        // 2. <Button>
        //        render(<TextAndIcon/>)
        //    </Button>
        //
        // 3. <Button>
        //       <Flow>
        //           render(<Text text="hi"/>)
        //       </Flow>
        //       <Flow>
        //           render(<Icon img="smiley" />)
        //       <Flow>
        //    </Button>
        //
        // ...
        var renderedElement:IElementUntyped = element.renderShallow(renderContext);

        // DomElement nodes are at the end of a sequence of renders. Might have children that need to be rendered. If this is not a
        // node of that type, we need to render the top-level node before attempting to render the children.
        if (!Std.is(renderedElement, IDomElement))
        {
            // Recurse. Output will be a DomElement
            renderedElement = render(renderedElement);
        }

        // TODO: Make this nicer. This runtime check is costly and the cast is unsafe.
        Assert.assert(Std.is(renderedElement, IDomElement));
        var renderedDomElement:IDomElementUntyped = cast renderedElement;

        // Extract props off the correctly-typed output
        var props:Props = renderedDomElement.props;

        // Get the original set of children from the props
        var inputChildren:Array<IElementUntyped> = PropsUtility.getChildren(props);

        // Render children, downcast so that we can handle them properly in cloneWithChildren
        var renderedChildren:Array<IElementUntyped> = inputChildren.map((childElement) -> cast(render(childElement), IElementUntyped));
        var outputProps = PropsUtility.cloneWithChildren(props, renderedChildren);

        return PropsUtility.withProps(renderedDomElement, outputProps);
    }

    public function renderAndApply(element:IElementUntyped, context:TContext):IDomEffect<TContext>
    {
        var domElement = render(element);
        return apply(domElement, context);
    }
    
    private function apply(domElement:IDomElementUntyped, context:TContext):IDomEffect<TContext>
    {
        var effectWalker = new SimpleEffectWalker(domElement, effectProvider);
        var effect = effectProvider.buildEffect(effectWalker);
        effect.apply(context);
        return effect;
    }

    private function applySimple(domElement:IDomElementUntyped, context:TContext):Void
    {
        // TODO: This is not type-safe. context is not guaranteed to match the input to applyShallow.
        var childContext:TContext = domElement.applyShallow(context, null);
        var childElements = PropsUtility.getChildren(domElement.props);
        for (childElement in childElements)
        {
            Assert.assert(Std.is(childElement, IDomElementUntyped));
            var childDomElement:IDomElementUntyped = cast childElement;
            apply(childDomElement,  childContext);
        }
    }
}
