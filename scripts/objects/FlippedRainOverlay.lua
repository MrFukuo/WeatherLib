local FlippedRainOverlay, super = Class(Object)

function FlippedRainOverlay:init(type, handler)
    super.init(self)
    self.type = type
    self.parallax_x, self.parallax_y = 0, 0
    self.handler = handler
    if handler.addto == Game.world then
        self:setLayer(WORLD_LAYERS["below_ui"])
    elseif handler.addto == Game.battle then
        self:setLayer(BATTLE_LAYERS["below_ui"])
    end
    self.paused = false
    if self.handler.pause then self.paused = true self.pause = true end

    if self.type == "hot" or self.type == "volcanic" then

        self.wave_shader = love.graphics.newShader([[
            extern number wave_sine;
            extern number wave_mag;
            extern number wave_height;
            extern vec2 texsize;
            vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
            {
                number i = texture_coords.x * texsize.x;
                vec2 coords = vec2(max(0.0, min(1.0, texture_coords.x + 0.0)), max(0.0, min(1.0, texture_coords.y + (sin((i / wave_height) + (wave_sine / 30.0)) * wave_mag) / texsize.y)));
                return Texel(texture, coords) * color;
            }
        ]])

        self.wave_fx = ShaderFX(self.wave_shader, {
            ["wave_sine"] = function() return Kristal.getTime() * 50 end,
            ["wave_mag"] = function () return 0.5 end,
            ["wave_height"] = function () return 8 end,
            ["texsize"] = {SCREEN_WIDTH, SCREEN_HEIGHT}
        }, false, 10)

        local NONONO = {
            LightMenu,
            LightItemMenu,
            LightCellMenu,
            LightStatMenu,
            BattleUI,
            TensionBar,
            Textbox
        }

        if not handler.addto:getFX("wave_fx") then
            for i, child in ipairs(handler.addto.children) do
                local number = 0
                for i, cc in ipairs(NONONO) do
                    if child:includes(cc) then
                        number = number + 1
                        break
                    end
                end
                if number == 0 and not self.paused then if not child:getFX("wave_fx") then child:addFX(self.wave_fx, "wave_fx") end end
            end
        end

        if not self.paused then self:addFX(self.wave_fx, "wave_fx") end
    end
    
    self.type = "flipped_rain"
end

function FlippedRainOverlay:draw()
    super.draw(self)
    local dark = 20

    if self.handler.addto == Game.world then
        if self.parent ~= Game.world then
            --local newx, newy = self.parent:getRelativePos(self.x, self.y, Game.world)
            self.parent:removeChild(self)
            Game.world:addChild(self)
            --self:setPosition(newx, newy)
        end
        if self.layer ~= WORLD_LAYERS["below_ui"] then
            self:setLayer(WORLD_LAYERS["below_ui"])
        end
    elseif self.handler.addto == Game.battle then
        if self.parent ~= Game.battle then
            --local newx, newy = self.parent:getRelativePos(self.x, self.y, Game.battle)
            self.parent:removeChild(self)
            Game.battle:addChild(self)
            --self:setPosition(newx, newy)
        end

        if self.layer ~= BATTLE_LAYERS["below_ui"] then
            self:setLayer(BATTLE_LAYERS["below_ui"])
        end
    end

    --if not Game.battle or (Game.battle and Game.battle.state ~= "TRANSITIONOUT") then
        if not self.paused then
                Draw.setColor((99 - dark)/255, (126 - dark)/255, (135 - dark)/255, 55/255)
                love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        end
    --end
end

return FlippedRainOverlay