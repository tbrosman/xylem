package xylem.heaps;

import xylem.render.domeffect.IDomEffect;
import xylem.render.domeffect.IDomEffectProvider;
import xylem.render.domeffect.IEffectWalker;
import h2d.Object;

class HeapsDomEffectProvider implements IDomEffectProvider<Object>
{
    public function new()
    {
    }

    public function buildEffect(effectWalker:IEffectWalker<h2d.Object>):IDomEffect<h2d.Object>
    {
        return new HeapsDomEffect(effectWalker);
    }
}