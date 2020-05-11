package xylem.render.hooks;

typedef StateHook<T> =
{
    function state():T;
    function setState(value:T):Void;
}