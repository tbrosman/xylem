package xylem.render.domeffect;

/**
 * DOM-agnostic logic for applying/unapplying an effect. DOM Effects encapsulate calls to IDomElement.applyShallow.
 */
interface IDomEffect<TContext>
{
    /**
     * Returns true if the effect is in an attached state. This means it can be applied without specifying a context.
     * @return Bool True if attached.
     */
    function attachedToDom():Bool;

    // TODO: Rename
    /**
     * Root case for applying an effect. Can only function if the effect has been previously applied (is attached to the DOM).
     */
    function applyRoot():Void;

    /**
     * Unapply an effect. Is recursive.
     */
    function unapply():Void;

    /**
     * Apply a DOM effect to a context (usually the parent in the DOM). Is recursive.
     * @param context The DOM context.
     */
    function apply(context:TContext):Void;
}
