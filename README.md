# Xylem

A React-inspired UI framework for the Haxe language. Initially supports Heaps.

## Overview

Xylem input trees are built using Elements. Elements take Props, which are specified as typedef objects. For example:

```haxe
new MyCoolElement({ color: 0xFF0000, width: 10, height: 20 })
```

This library leverages the structInit feature of Haxe to make these constructor calls readable. There is a special "children" prop that behaves similar to React. If you wanted to render a health bar with a background, you might create the following tree:

```haxe
new PositionedElement({
    position: new Vector2(x, y),
    children: [
        new RectElement({
            fill: 0x000000,
            rect: new Rect(0, 0, width, height)
        }),
        new RectElement({
            fill: 0xFFFFFF,
            rect: new Rect(0, 0, (current / max) * width, height)
        })
    ]
});
```

In the case of Heaps, this tells Xylem:

* Create an empty h2d.Object with position (x, y)
* Add two h2d.Graphics objects drawing rectangles as children

To see the output in Heaps, use one of the provided Renderers to render and apply the Element:

```haxe
var parent:h2d.Object = ... // Get a parent object to apply the tree to
var element = ... // See above
var renderer = RendererFactory.buildLazyRenderer();
renderer.renderAndApply(element, parentHeapsObject);
```

## FAQ

Q: Why is it called Xylem?
A: [Xylem](https://en.wikipedia.org/wiki/Xylem) is the stuff that trees are made of. Much like React, it is a framework for transforming trees of Elements and then applying side-effects to something DOM-like.

Q: How much of the React API surface is supported?
A: Not much. This is mostly an experiment to see if I could replicate some of the laziness characteristics of React's Fiber reconciler. You can:

* Build Elements that output other Elements (note: probably should be called "Component"; naming needs some cleanup)
* Perform side-effect-y operations in a useEffect hook (e.g. like setting state)
* Apply DomElements to Heaps object trees
