Render the top-level Elements element first. Then render Elements below it.
Example: say we have `<ButtonWithTextAndIcon/>` as a starting point.

```
1. render(<ButtonWithTextAndIcon/>)

1.5. render (
        <Button>
            render(<TextAndIcon/>)
        </Button>
    )

2. <Button>
       render(<TextAndIcon/>)
   </Button>

2.5. <Button>
        render(
            <Flow>
                <Text text="hi"/>
                <Icon img="smiley" />
            <Flow>
        )
    </Button>

3.  <Button>
        <Flow>
            render(<Text text="hi"/>)
            render(<Icon img="smiley" />)
        <Flow>
    </Button>

4.  <Button>
        <Flow>
            <Text text="hi"/>
            <Tile img="smiley" />
        <Flow>
    </Button>
```

Now say we have `<TurnsIntoTwoHighLevelElements/>`

```
1. render(<TurnsIntoTwoHighLevelElements/>)

2. render(
       <PositionInFlow>
          <HighLevelElementA/>
          <HighLevelElementB/>
       </PositionInFlow>
   )

3. <Flow>
       render(<HighLevelElementA/>)
       render(<HighLevelElementB/>)
   </Flow>

...
```