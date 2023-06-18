menu.add_feature("Crash Everijuan", "action", 0, function(f)
    local pos = player.get_player_coords(player.player_id())
    pos.x = pos.x + 5
    rope.add_rope(pos, v3(0, 0, 0), 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1.0, true)
    menu.notify("Crash applied, say bai bai.", "Crash")
end)
