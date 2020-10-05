local file_map = require("file_map")

-- replace all translated images in raw.table
checkData = function(table)
	for key,item in pairs(table) do
		if (type(item) == "string") then
			new_value = file_map[item]
			if file_map[item] ~= nil then
				table[key] = file_map[item]
			end

		elseif (type(item) == "table") then
			checkData(item)
		end
	end
end

checkData(data.raw)



-- desaturate the map
local function desaturate(c, bri, sat)
	-- colors can be either named, on indexed. They also can be valued [0-1] or [0-255], but that doesn't matter for this maths
	r = c.r or c[1]
	g = c.g or c[2]
	b = c.b or c[3]
	a = c.a or c[4] or 1

	-- Numbers taken from factorio's shader. Keep in sync with run-conversion.py
	ret = {
		r = (r*(0.3086 + 0.6914*sat) + g*(0.6094 - 0.6094*sat) + b*(0.0820 - 0.0820*sat)) * bri,
		g = (r*(0.3086 - 0.3086*sat) + g*(0.6094 + 0.3906*sat) + b*(0.0820 - 0.0820*sat)) * bri,
		b = (r*(0.3086 - 0.3086*sat) + g*(0.6094 - 0.6094*sat) + b*(0.0820 + 0.9180*sat)) * bri,
		a = a,
	}

	return ret
end


for entity_group_name, entity_group in pairs(data.raw) do
	for _, entity in pairs(entity_group) do
		if entity.map_color ~= nil then
			entity.map_color = desaturate(entity.map_color, 0.7, 0.1)
		end

		if entity.friendly_map_color ~= nil then
			entity.friendly_map_color = desaturate(entity.friendly_map_color, 0.7, 0.1)
		end

		if entity.enemy_map_color ~= nil then
			entity.enemy_map_color = desaturate(entity.enemy_map_color, 0.7, 0.1)
		end
	end
end


-- There are a bunch of default colors in UtilityConstants.chart for the map that we must desaturate too
local function desaturate_table(t, sat, bri, postfix)
	for k, v in pairs(t) do
		if postfix == nil or k:sub(-#postfix) == postfix then
			t[k] = desaturate(t[k], sat, bri)
		end
	end
end
desaturate_table(data.raw["utility-constants"].default.chart, 0.7, 0.1, "_color")
desaturate_table(data.raw["utility-constants"].default.chart.default_color_by_type, 0.7, 0.1)
desaturate_table(data.raw["utility-constants"].default.chart.default_friendly_color_by_type, 0.7, 0.1)


