function pick_decor_obj()
{
    var r = irandom(99);
    if (r < 5)
    {
        return obj_deco_volcano;
    }
    else if (r < 50)
    {
        return obj_deco_tree_tall;
    }
    else
    {
        return obj_deco_tree_cluster;
    }
}

function column_ground(arg0, arg1, arg2, arg3)
{
    for (var yy = arg1; yy <= arg2; yy += arg3)
    {
        var obj = choose(obj_solid_neon, obj_solid_neon_brick);
        instance_create_layer(arg0, yy, "Instances", obj);
    }
}

function build_pit_lava_column(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
{
    var gap_width = (arg2 - arg1) + 1;
    var index_in_gap = arg0 - arg1;
    var y_surface = arg4 + (arg6 * 2);
    var y_mid = y_surface + arg6;
    var y_bottom = y_surface + (arg6 * 2);
    instance_create_layer(arg3, y_surface, "Instances", obj_lava_surface);
    instance_create_layer(arg3, y_mid, "Instances", obj_lava_fill);
    var bottom_obj;
    if (gap_width == 1)
    {
        bottom_obj = obj_lava_bottom_mid;
    }
    else if (index_in_gap == 0)
    {
        bottom_obj = obj_lava_bottom_left;
    }
    else if (index_in_gap == (gap_width - 1))
    {
        bottom_obj = obj_lava_bottom_right;
    }
    else
    {
        bottom_obj = obj_lava_bottom_mid;
    }
    instance_create_layer(arg3, y_bottom, "Instances", bottom_obj);
}

function build_air_hazard_line(arg0, arg1, arg2, arg3)
{
    if (arg2 <= 0)
    {
        exit;
    }
    var support_y = arg1 + (arg3 * 0.5);
    if (arg2 == 1)
    {
        instance_create_layer(arg0, arg1, "Instances", obj_airhaz_single);
        instance_create_layer(arg0, support_y, "Instances", obj_airhaz_support);
        exit;
    }
    var last = arg2 - 1;
    for (var j = 0; j < arg2; j++)
    {
        var xx = arg0 + (j * arg3);
        var hz_obj;
        if (j == 0)
        {
            hz_obj = obj_airhaz_left;
        }
        else if (j == last)
        {
            hz_obj = obj_airhaz_right;
        }
        else
        {
            hz_obj = obj_airhaz_mid;
        }
        instance_create_layer(xx, arg1, "Instances", hz_obj);
        instance_create_layer(xx, support_y, "Instances", obj_airhaz_support);
    }
}

function seg_flat_run(arg0, arg1, arg2, arg3, arg4)
{
    var tiles = arg3 div arg4;
    for (var i = 0; i < tiles; i++)
    {
        var xx = arg0 + (i * arg4);
        column_ground(xx, arg1, arg2, arg4);
    }
    var center_tile = tiles div 2;
    var deco_x = arg0 + (center_tile * arg4) + (arg4 * 0.5);
    var deco_y = arg1;
    var deco_obj = pick_decor_obj();
    instance_create_layer(deco_x, deco_y, "Instances", deco_obj);
}

function seg_small_gap(arg0, arg1, arg2, arg3, arg4)
{
    var tiles = arg3 div arg4;
    var gap_pos = tiles div 2;
    var gap_w = 3;
    var gap_start = gap_pos;
    var gap_end = (gap_pos + gap_w) - 1;
    for (var i = 0; i < tiles; i++)
    {
        var xx = arg0 + (i * arg4);
        if (i >= gap_start && i <= gap_end)
        {
            build_pit_lava_column(i, gap_start, gap_end, xx, arg1, arg2, arg4);
        }
        else
        {
            column_ground(xx, arg1, arg2, arg4);
        }
    }
}

function seg_upper_step(arg0, arg1, arg2, arg3, arg4)
{
    var tiles = arg3 div arg4;
    var air_y = arg1 - (arg4 * 3);
    var use_gold = irandom(1) == 0;
    for (var i = 0; i < tiles; i++)
    {
        var xx = arg0 + (i * arg4);
        column_ground(xx, arg1, arg2, arg4);
        if (i > (tiles div 2))
        {
            var obj = use_gold ? obj_solid_gold : obj_solid_skyblue;
            instance_create_layer(xx, air_y, "Instances", obj);
        }
    }
    var center_tile = tiles div 2;
    var deco_x = arg0 + (center_tile * arg4) + (arg4 * 0.5);
    var deco_y = arg1;
    var deco_obj = pick_decor_obj();
    instance_create_layer(deco_x, deco_y, "Instances", deco_obj);
}

function seg_air_hazard(arg0, arg1, arg2, arg3, arg4)
{
    var tiles = arg3 div arg4;
    for (var i = 0; i < tiles; i++)
    {
        var xx = arg0 + (i * arg4);
        column_ground(xx, arg1, arg2, arg4);
    }
    var hazard_tiles = choose(1, 3, 5);
    var air_y = arg1 - (arg4 * 5);
    var start_tile = max(tiles div 2, tiles - hazard_tiles - 2);
    var hazard_x = arg0 + (start_tile * arg4);
    build_air_hazard_line(hazard_x, air_y, hazard_tiles, arg4);
    var ground_center_tile = tiles div 2;
    var deco_x = arg0 + (ground_center_tile * arg4) + (arg4 * 0.5);
    var deco_y = arg1;
    var deco_obj = pick_decor_obj();
    instance_create_layer(deco_x, deco_y, "Instances", deco_obj);
}

function seg_goal(arg0, arg1, arg2, arg3, arg4)
{
    var tiles = arg3 div arg4;
    for (var i = 0; i < tiles; i++)
    {
        var xx = arg0 + (i * arg4);
        column_ground(xx, arg1, arg2, arg4);
    }
    var deco_x = arg0 + ((tiles div 2) * arg4) + (arg4 * 0.5);
    var deco_y = arg1;
    var deco_obj = pick_decor_obj();
    instance_create_layer(deco_x, deco_y, "Instances", deco_obj);
    var end_x = (arg0 + arg3) - (arg4 * 2);
    instance_create_layer(end_x, arg1 - (arg4 * 3), "Instances", obj_level_end);
}
