package xylem.render;

/**
 * Describes which kind of render is taking place. Used by Effects.
 */
enum RenderMode
{
    // The first time a particular Element instance renders
    Mount;

    // Subsequent renders
    Update;
}
