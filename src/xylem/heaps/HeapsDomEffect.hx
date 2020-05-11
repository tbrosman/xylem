package xylem.heaps;

import xylem.diagnostics.Assert;
import xylem.IDomElement.IDomElementUntyped;
import xylem.render.domeffect.IDomEffect;
import xylem.render.domeffect.IEffectWalker;
import h2d.Object;

class HeapsDomEffect implements IDomEffect<h2d.Object>
{
    // The DOM object corresponding to the owning Node. Only non-null if element is a IDomElement.
    private var domObject:Null<Object>;

    private var lastParentDomObject:Null<Object>;

    private var effectWalker:IEffectWalker<h2d.Object>;

    public function new(effectWalker:IEffectWalker<h2d.Object>)
    {
        this.effectWalker = effectWalker;
    }

    public function attachedToDom():Bool
    {
        return lastParentDomObject != null;
    }

    public function applyRoot():Void
    {
        apply(lastParentDomObject);
    }

    public function unapply():Void
    {
        if (domObject != null)
        {
            domObject.remove();
            domObject = null;
        }
    }
    
    /**
     * Applies the DOM effect to the Heaps tree.
     * @param parentDomObject The parent Heaps object.
     */
    public function apply(parentDomObject:h2d.Object):Void
    {
        // If there is a different parent, the old domObject is now orphaned. The most correct thing to do is create a new one instead
        // of attempting an update in place.
        if (parentDomObject != lastParentDomObject)
        {
            domObject = null;
        }

        lastParentDomObject = parentDomObject;
        var element = effectWalker.getElement();

        if (!Std.is(element, IDomElement))
        {
            Assert.assert(element != null);
            effectWalker.getOutputEffect().apply(parentDomObject);
        }
        else
        {
            var domElement:IDomElementUntyped = cast element;
            var newDomObject = domElement.applyShallow(parentDomObject, domObject);
            if (domObject != null && newDomObject != domObject)
            {
                // Remove the old object
                domObject.remove();
            }

            // Point to the new/updated object in the DOM
            domObject = newDomObject;

            for (childEffect in effectWalker.getChildEffects())
            {
                childEffect.apply(domObject);
            }
        }
    }

    public function applyUntyped(context:Dynamic):Void
    {
        apply(cast context);
    }
}
