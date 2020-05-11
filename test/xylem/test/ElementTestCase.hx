package xylem.test;

import xylem.IElement;
import xylem.Props.PropsUtility;
import xylem.test.elements.CustomTextButtonElement;
import xylem.render.Node;
import xylem.heaps.HeapsDomEffectProvider;
import xylem.heaps.RendererFactory;
import xylem.test.elements.DoubleMockElement;
import xylem.test.elements.MockDomElement;
import xylem.test.elements.MockElement;
import xylem.test.elements.StateSetterElement;
import xylem.test.elements.ToggleButtonElement;
import xylem.test.elements.SubscribingElement;
import xylem.test.elements.MultiplierElement;
import h2d.Flow;
import h2d.Object;
import haxe.unit.TestCase;
import hxd.App;
import hxmath.math.Vector2;

using Lambda;

@:structInit
class NodeAssertion
{
    public final elementType:Class<IElementUntyped>;
    public final outputExists:Bool;
    public final childCount:Int;
}

class ElementTestCase extends TestCase
{
    public function new()
    {
        super();
    }

    /**
     * Nodes should evict old Element -> Node mappings from the LazyRenderer cache.
     */
    public function testLazyRendererEviction()
    {
        var renderer = RendererFactory.buildLazyRenderer();
        var node = renderer.buildOrGetNode(new MockElement({ name: "Test" }));

        var props2:MockProps = { name: "Test2" };
        node.tryUpdateWithProps(props2);
        var cachedNode = renderer.tryGetNode(node.element);
        assertEquals(node, cachedNode);
        assertEquals(2, renderer.getNodeCount());
    }

    /**
     * Tests that rendering CustomTextButtonElement has no side-effects that require Heaps (e.g. allocating textures).
     */
    public function testCustomElement_rendersWithoutHeaps()
    {
        var didThrow = false;
        try 
        {
            var element = new CustomTextButtonElement({ text: "asdf", position: new Vector2(10, 10), textScale: 5.0, onClick: null });
            var _ = RendererFactory.buildSimpleRenderer().render(element);
        }
        catch (ex:Dynamic)
        {
            didThrow = true;
        }

        assertTrue(!didThrow);
    }

    public function testLazyRendererNode()
    {
        var element = new DoubleMockElement({
            name1: "Top1",
            name2: "Top2",
            children: [
                new MockElement({
                    name: "Middle",
                    children: [
                        new MockElement({ name: "Child1" }),
                        new MockElement({ name: "Child2" })
                    ]
                })
            ]
        });
        
        /*
        Evolution:

        DoubleMock(Top1, Top2)*
            Mock(Middle)
                Mock(Child1)
                Mock(Child2)

        ->

        Mock(Top1)*
            Mock(Top2)
                Mock(Child1)
                Mock(Child2)

        ->

        MockDom(Top1) - recurse children
            Mock(Top2)*
                Mock(Child1)
                Mock(Child2)

        ->

        MockDom(Top1)
            MockDom(Top2) - recurse children
                Mock(Child1)*
                Mock(Child2)

        -> 

        MockDom(Top1)
            MockDom(Top2) - recurse children
                MockDom(Child1)
                Mock(Child2)*

        ->

        MockDom(Top1)
            MockDom(Top2)
                MockDom(Child1)
                MockDom(Child2)

        Links in Node tree:

        a. DoubleMock(Top1, Top2) -> (b)
            Mock(Middle)
            Mock(Child1)
                Mock(Child2)

        b. Mock(Top1) -> c
            Mock(Top2)
                ...

        c. MockDom(Top1)
           d. Mock(Top2) -> e
                ...

        e. MockDom(Top2)
            f. Mock(Middle) -> g
                ...

        g. MockDom(Middle)
            h. Mock(Child1) -> i
            j. Mock(Child2) -> k

        i. MockDom(Child1)

        k. MockDom(Child2)
        */

        // Names are given in terms of path through the graph. Example:
        // node_out_child0 = 0th child of the output of the starting node

        var node = Node.build(cast element, new HeapsDomEffectProvider());
        assertEquals(11, countNodes(node));

        assertNodeMatches(node, { elementType: DoubleMockElement, outputExists: true, childCount: 0 });
        
        var node_out = node.output;
        assertNodeMatches(node_out, { elementType: MockElement, outputExists: true, childCount: 0 });
        assertMockElementName("Top1", node_out.element);

        var node_out2 = node_out.output;
        assertNodeMatches(node_out2, { elementType: MockDomElement, outputExists: false, childCount: 1 });

        var node_out2_child0 = node_out2.children[0];
        assertNodeMatches(node_out2_child0, { elementType: MockElement, outputExists: true, childCount: 0 });
        assertMockElementName("Top2", node_out2_child0.element);

        var node_out2_child0_out = node_out2_child0.output;
        assertNodeMatches(node_out2_child0_out, { elementType: MockDomElement, outputExists: false, childCount: 1 });

        var node_out2_child0_out_child0 = node_out2_child0_out.children[0];
        assertNodeMatches(node_out2_child0_out_child0, { elementType: MockElement, outputExists: true, childCount: 0 });
        assertMockElementName("Middle", node_out2_child0_out_child0.element);

        var node_out2_child0_out_child0_out = node_out2_child0_out_child0.output;
        assertNodeMatches(node_out2_child0_out_child0_out, { elementType: MockDomElement, outputExists: false, childCount: 2 });

        var root = new h2d.Object();
        node.effect.apply(root);
        assertEquals(1, root.numChildren);

        var top1 = root.getChildAt(0);
        assertEquals("Top1", top1.name);
        assertEquals(1, top1.numChildren);

        var top2 = top1.getChildAt(0);
        assertEquals("Top2", top2.name);
        assertEquals(1, top2.numChildren);

        var middle = top2.getChildAt(0);
        assertEquals("Middle", middle.name);
        assertEquals(2, middle.numChildren);

        var child1 = middle.getChildAt(0);
        assertEquals("Child1", child1.name);
        assertEquals(0, child1.numChildren);

        var child2 = middle.getChildAt(1);
        assertEquals("Child2", child2.name);
        assertEquals(0, child2.numChildren);
    }
    
    public function testCustomElement_rendersWithLazyRenderer()
    {
        var element = new CustomTextButtonElement({ text: "asdf", position: new Vector2(10, 10), textScale: 5.0, onClick: null });
        var simpleRendererOutputElement = RendererFactory.buildSimpleRenderer().render(element);
        var lazyRendererOutputElement = RendererFactory.buildLazyRenderer().render(element);

        assertSameElement(simpleRendererOutputElement, lazyRendererOutputElement);
        
        var simpleChildren = PropsUtility.getChildren(simpleRendererOutputElement.props);
        var lazyChildren = PropsUtility.getChildren(lazyRendererOutputElement.props);
        assertTrue(simpleChildren.length == lazyChildren.length);

        for (i in 0...simpleChildren.length)
        {
            assertSameElement(simpleChildren[i], lazyChildren[i]);
        }
    }

    public function testSimpleRenderer_renderAndApply()
    {
        var element = new MockDomElement({ name: "test", children: [
            new MockDomElement({ name: "test2" })
        ]});

        var root = new h2d.Object();
        RendererFactory.buildSimpleRenderer().renderAndApply(element, root);
        assertEquals(1, root.numChildren);

        var child = root.getChildAt(0);
        assertEquals("test", child.name);
        assertEquals(1, child.numChildren);

        var grandChild = child.getChildAt(0);
        assertEquals("test2", grandChild.name);
        assertEquals(0, grandChild.numChildren);
    }

    public function testSimpleRender_cleanupDomEffectManually()
    {
        var element = new MockDomElement({ name: "test", children: [
            new MockDomElement({ name: "test2" })
        ]});

        var root = new h2d.Object();
        var effect = RendererFactory.buildSimpleRenderer().renderAndApply(element, root);
        assertEquals(1, root.numChildren);

        effect.unapply();
        assertEquals(0, root.numChildren);
    }

    public function testStateEffect()
    {
        var renderer = RendererFactory.buildLazyRenderer();
        var element = new StateSetterElement({ name: "a", nameLater: "b" });
        var outputDomElement:MockDomElement = cast renderer.render(element);
        assertEquals("b", outputDomElement.props.name);
    }

    // State changing due to external subscription (something "pushes" state to the Element)
    public function testExternalStateEffect()
    {
        var renderer = RendererFactory.buildLazyRenderer();
        var subscriptionBus = new SubscriptionBus();
        var element = new SubscribingElement({ name: "a", subscriptionBus: subscriptionBus });
        
        var outputDomElement:MockDomElement = cast renderer.render(element);
        assertEquals("a", outputDomElement.props.name);

        subscriptionBus.set("b");
        var outputDomElementAfter:MockDomElement = cast renderer.render(element);
        assertEquals("b", outputDomElementAfter.props.name);
    }

    public function testNodeDispose()
    {
        var mockTree = new MockElement({
            name: "Middle",
            children: [
                new MockElement({ name: "Child1" }),
                new MockElement({ name: "Child2" })
            ]
        });

        var renderer = RendererFactory.buildLazyRenderer();
        var rootNode = renderer.buildOrGetNode(mockTree);

        rootNode.dispose();
        assertEquals(0, renderer.getNodeCount());
        assertEquals(null, rootNode.output);
    }

    public function testExternalStateEffectDisposedNode()
    {
        var renderer = RendererFactory.buildLazyRenderer();
        var subscriptionBus = new SubscriptionBus();
        var element = new SubscribingElement({ name: "a", subscriptionBus: subscriptionBus });
        
        // Render once, then dispose the corresponding Node
        var node = renderer.buildOrGetNode(element);
        node.dispose();

        assertTrue(!subscriptionBus.hasSubscriber);
    }

    public function testCleanupAfterElementDelete()
    {
        var multiplier = new MultiplierElement({
            name: "multiplier",
            count: 3
        });

        var renderer = RendererFactory.buildLazyRenderer();
        var rootNode:Node = renderer.buildOrGetNode(multiplier);
        var rootMockDom:Node = rootNode.output.output;
        assertEquals(3, rootMockDom.children.length);

        // This is the Node for the last MockElement child
        var lastOutputChild = rootMockDom.children[2];
        assertTrue(lastOutputChild.output != null);

        // Slightly unsafe, but okay in tests
        rootNode.hooks.setState({ count: 2 });
        assertEquals(2, rootMockDom.children.length);
        assertTrue(lastOutputChild.output == null);
    }

    private function assertMockElementName(name:String, element:IElementUntyped)
    {
        var mockElement:MockElement = cast element;
        assertEquals(name, mockElement.props.name);
    }

    private function assertNodeMatches(node:Node, nodeAssertion:NodeAssertion):Void
    {
        assertElementType(nodeAssertion.elementType, node.element);
        assertTrue(node.output != null == nodeAssertion.outputExists);
        assertEquals(nodeAssertion.childCount, node.children.length);
    }

    private function assertElementType<TElement:IElementUntyped>(expectedElementType:Class<TElement>, actualElement:IElementUntyped):Void
    {
        assertEquals(cast(expectedElementType, Class<Dynamic>), Type.getClass(actualElement));
    }

    private function assertSameElement(expectedElement:IElementUntyped, actualElement:IElementUntyped):Void
    {
        assertEquals(Type.getClass(expectedElement), Type.getClass(actualElement));
    }

    private function countNodes(node:Node)
    {
        if (node != null)
        {
            return 1 +
                countNodes(node.output) +
                node.children
                    .map(child -> countNodes(child))
                    .fold((a, b) -> a + b, 0);
        }

        return 0;
    }
}