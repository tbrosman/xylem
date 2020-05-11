package ;

import xylem.test.ElementTestCase;
import haxe.unit.TestRunner;

class TestMain
{
    public static function main():Void
    {
        var runner = new TestRunner();
        runner.add(new ElementTestCase());
        runner.run();
    }
}
