// =============================================================================
//  catppuccin-mocha theme — renderer shaders
//  Deploy to <gamedir>/scripts/ . Loaded at renderer init (a vid_restart picks
//  up edits). The theme .cfg (themes/catppuccin-mocha.cfg) remaps UrT's UI
//  shaders onto these via the remapShader command.
//
//  Two techniques recur:
//   - blendfunc blend : draw the texture with its OWN alpha, so shaped widgets
//                       (arrows, corner, slider knob) keep transparent edges.
//   - rgbGen identity : force the texture's colour and IGNORE the per-element
//                       colour the UI VM passes. UrT tints backdrops/panels/tabs
//                       per screen/state; without this they'd come out wrong.
// =============================================================================

// --- Backdrops ---------------------------------------------------------------

// Draws nothing (dst*1 + src*0): used to ERASE the animated menu decoration
// (diagonal lines + arc) for a clean flat background.
theme/catppuccin/hidden
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/blank.tga
		blendFunc GL_ZERO GL_ONE
	}
}

// Opaque base-colour full-screen fill. UrT tints ut_menuback per screen (bright
// on the main menu, near-black elsewhere); rgbGen identity makes it uniform.
theme/catppuccin/fill_base
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/base.tga
		rgbGen identity
	}
}

// Semi-transparent base panel for the in-game menus, so the game still shows
// through behind the menu (alphaGen const = opacity; tweak 0.0–1.0).
theme/catppuccin/panel
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/base.tga
		blendfunc blend
		rgbGen identity
		alphaGen const 0.90
	}
}

// --- Tabs --------------------------------------------------------------------
// Dialog tabs / menu bands. tab = unselected (gray), tab_on = selected (blue).
// The .tga bakes a thin fully-transparent strip on the right edge so adjacent
// tabs show a small gap. rgbGen identity forces the colour over UrT's tint.
theme/catppuccin/tab
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/tab.tga
		blendfunc blend
		rgbGen identity
	}
}

theme/catppuccin/tab_on
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/tab_on.tga
		blendfunc blend
		rgbGen identity
	}
}

// --- Widgets (alpha-blended shaped art) --------------------------------------
// Each maps a shaped RGBA texture; blendfunc blend keeps the transparent
// background of the shape. Colour is baked into the texture.

// Panel folded corner (normal + hover)
theme/catppuccin/angle
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/angle.tga
		blendfunc blend
	}
}

theme/catppuccin/angle_on
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/angle_on.tga
		blendfunc blend
	}
}

// Scrollbar: track + thumb
theme/catppuccin/scrollbar
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/scrollbar.tga
		blendfunc blend
	}
}

theme/catppuccin/scrollbar_thumb
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/scrollbar_thumb.tga
		blendfunc blend
	}
}

// Scrollbar arrow buttons (up / down / left / right)
theme/catppuccin/arrow_up
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/arrow_up.tga
		blendfunc blend
	}
}

theme/catppuccin/arrow_dwn
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/arrow_dwn.tga
		blendfunc blend
	}
}

theme/catppuccin/arrow_left
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/arrow_left.tga
		blendfunc blend
	}
}

theme/catppuccin/arrow_right
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/arrow_right.tga
		blendfunc blend
	}
}

// Slider: track + knob
theme/catppuccin/slider
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/slider.tga
		blendfunc blend
	}
}

theme/catppuccin/sliderbutt
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/sliderbutt.tga
		blendfunc blend
	}
}

// Navigation arrows: back (neutral / blue hover), accept (green / lighter hover)
theme/catppuccin/backarrow
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/backarrow.tga
		blendfunc blend
	}
}

theme/catppuccin/backarrow_on
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/backarrow_on.tga
		blendfunc blend
	}
}

theme/catppuccin/acceptarrow
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/acceptarrow.tga
		blendfunc blend
	}
}

theme/catppuccin/acceptarrow_on
{
	nopicmip
	nomipmaps
	{
		map theme/catppuccin/acceptarrow_on.tga
		blendfunc blend
	}
}
