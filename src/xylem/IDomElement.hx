package xylem;

/**
 * DomElements can be rendered into Heaps objects.
 */
 interface IDomElement<TProps:Props, TState, TContext> extends IElement<TProps, TState>
 {
     /**
      * Build the corresponding Heaps object for this Element. Does not recurse through descendants. Note that even if an existing
      * object is specified, this function can ignore it and build a new object.
      * @param parent The parent to attach the output to.
      * @param existing (optional) An existing object. Guaranteed to be previously constructed for this Element.
      * @return Object The output object (a child of the parent that was passed in).
      */
     function applyShallow(parent:TContext, existing:TContext):TContext;
 }

 typedef IDomElementUntyped = IDomElement<Dynamic, Dynamic, Dynamic>;
 
 /**
  * Sometimes we need to perform a side-effect-y operation like allocate textures. There are a couple options for implementing this
  * behavior in a safe way:
  * 
  * a. Create a set of boilerplate Element classes for each way you could construct the thing. In the case of h2d.Tile there are 4
  * common factory methods and the constructor has 7 parameters. This would require a lot of code.
  * 
  * b. Wrap the side effect in a delegate. This isn't declarative at all, but accommodates foreign API calls after initial construction
  * and requires almost no code. The drawback is that you can never inspect the values.
  * 
  * This is option (b).
  */
  typedef Builder<TOutput> = () -> TOutput;
 