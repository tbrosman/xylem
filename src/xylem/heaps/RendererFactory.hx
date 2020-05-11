package xylem.heaps;

import xylem.render.LazyRenderer;
import xylem.render.SimpleRenderer;

class RendererFactory
{
    public static function buildLazyRenderer():LazyRenderer<h2d.Object>
    {
        return new LazyRenderer(new HeapsDomEffectProvider());
    }

    public static function buildSimpleRenderer():SimpleRenderer<h2d.Object>
    {
        return new SimpleRenderer(new HeapsDomEffectProvider());
    }
}