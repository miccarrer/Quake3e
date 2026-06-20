// Catppuccin theme helper shaders.
// "hidden" draws nothing: blendFunc GL_ZERO GL_ONE keeps the background pixels
// untouched, so remapping a decoration shader to it makes it truly invisible
// (unlike remapping to an image, which paints an opaque quad).
theme/catppuccin/hidden
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/blank.tga
		blendFunc GL_ZERO GL_ONE
	}
}
