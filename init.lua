dofile("mods/da_zoomer/lib/script_utilities.lua")
dofile("mods/da_zoomer/lib/math-round.lua")

local newRes_y = math.round(ModSettingGetNextValue("da_zoomer.resolution"))
local newRes_x = math.round(newRes_y / 0.5625) -- Game forces 16:9 aspect
local scale = (newRes_y / 240.0)
local chunks = math.max(math.round(ModSettingGetNextValue("da_zoomer.chunks")), math.ceil((newRes_x / 512) + 1) * math.ceil((newRes_y / 512) + 1))
if (ModSettingGetNextValue("da_zoomer.double_chunks")) then chunks = chunks * 2 end

-- Files
local post_final_frag = "data/shaders/post_final.frag"
local post_final_vert = "data/shaders/post_final.vert"
local post_glow1_frag = "data/shaders/post_glow1.frag"
local post_glow2_frag = "data/shaders/post_glow2.frag"
local magic_numbers_xml = "mods/da_zoomer/files/magic_numbers.xml"

-- Set Resolution
script.replace("const float SCREEN_W = "..(newRes_x)..".0;", "const float SCREEN_W = 427.0;", post_final_frag)
script.replace("const float SCREEN_H = "..(newRes_y + 2)..".0;", "const float SCREEN_H = 242.0;", post_final_frag) -- +2 to prevent pixels disappearing from the top and bottom.
script.replace([[VIRTUAL_RESOLUTION_X="]]..(newRes_x)..[["]], [[VIRTUAL_RESOLUTION_X="427"]], magic_numbers_xml)
script.replace([[VIRTUAL_RESOLUTION_Y="]]..(newRes_y + 2)..[["]], [[VIRTUAL_RESOLUTION_Y="242"]], magic_numbers_xml) -- +2 to prevent pixels disappearing from the top and bottom.

-- Fix Glow
script.replace("vec2 tex_coord_glow = tex_coord_glow_ - (("..scale.." - 1.0) / world_viewport_size);", "vec2 tex_coord_glow = tex_coord_glow_;", post_final_frag)
script.replace("vec2 offset = one_per_glow_texture_size * 1.5 * "..scale..";", "vec2 offset = one_per_glow_texture_size * 1.5;", post_glow1_frag)
script.replace("vec2 offset = one_per_glow_texture_size * 1.5 * "..scale..";", "vec2 offset = one_per_glow_texture_size * 1.5;", post_glow2_frag)

-- Fix Fog and Sky Offsets
script.replace("float SKY_Y_OFFSET = 55.0 * "..scale..";", "const float SKY_Y_OFFSET   = 55.0;", post_final_vert)
script.replace("float FOG_Y_OFFSET = 90.0 * camera_inv_zoom_ratio * "..scale..";", "float FOG_Y_OFFSET   = 90.0 * camera_inv_zoom_ratio;", post_final_vert)

-- Fix Distortion
script.replace("const float DISTORTION_SCALE_MULT = 50.0 / "..scale..";", "const float DISTORTION_SCALE_MULT 		= 50.0;", post_final_frag)
script.replace("const float DISTORTION_SCALE_MULT2 = 0.002 / "..scale..";", "const float DISTORTION_SCALE_MULT2 		= 0.002;", post_final_frag)
script.replace("vec4 extra_data_at_liquid_offset = texture2D( tex_glow_unfiltered, tex_coord_glow + vec2(liquid_distortion_offset.x, -liquid_distortion_offset.y) * 10.0 );", "vec4 extra_data_at_liquid_offset = texture2D( tex_glow_unfiltered, tex_coord_glow + vec2( liquid_distortion_offset.x, -liquid_distortion_offset.y ) );", post_final_frag)

-- Adjust Chunks
script.replace([[STREAMING_CHUNK_TARGET="]]..chunks..[["]], [[STREAMING_CHUNK_TARGET="10"]], magic_numbers_xml)

ModMagicNumbersFileAdd(magic_numbers_xml)