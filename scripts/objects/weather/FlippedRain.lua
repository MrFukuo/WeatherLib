-- CUSTOM WEATHER TUTORIAL


local FlippedRain, super = Class(WeatherHandler, "flipped_rain") -- the id ("flipped-rain") MUST be the type of weather defined in lib.json!

function FlippedRain:init(sfx, child, intensity, overlay)

    super.init(self)
    -- INITIAL STUFF
    self.type = self.id
    self.sfx = sfx or true
    self.addto = child or Game.stage:getWeatherParent()
    self.intensity = intensity or 1
    self.haveoverlay = overlay
    if self.haveoverlay then self:addOverlay() end

    self.pause = false

    -- TIMERS
    self.fraintimer = 0
    self.fraintimerthres = 0
    self.fraintimerreset = true

    -- MUSIC
    if self.sfx then self.weathersounds:play("light_rain", 2, 1) end
    
end

function FlippedRain:update()
    super.update(self)

    if not self.pause then -- for general purposes, it's "if not indoors then"
        if self.type == "flipped_rain" then
            if self.fraintimerreset then
                self.fraintimerreset = false
                self.fraintimerthres = math.random(1, 6)
            elseif self.fraintimer >= self.fraintimerthres then

                self.fraintimer = 0
                self.fraintimerreset = true

                local amount = self.intensity

                local speedmult = self.intensity

                for _ = amount, 1, -1 do

                    for i = 6, 1, -1 do

                        local a = 0.25 * (i - 1)
                        local b = 0.25 * i

                        local number = Utils.pick({"three", "five", "six", "nine", "nine_alt"})
                        local x = math.random(SCREEN_WIDTH * a, SCREEN_WIDTH * b)
                        local y = math.random(0, 40)
                        local worldx, worldy = self:getRelativePos(x, 0 - y, self.addto)
                        local rain = FlippedRainPiece("world/flippedrain", number, worldx - SCREEN_WIDTH/2, worldy, speedmult * 20, self)
                        if self:getRainPieces() < 45 then self.addto:addChild(rain) end -- controls how many pieces can be on the screen at once

                    end
                end

            end
            self.fraintimer = self.fraintimer + 1 * DTMULT
            --print(self.fraintimer, self.fraintimerthres)
        end
    end
end 

function FlippedRain:getRainPieces() -- flipped_rain specific function
    local number = 0
    for i, child in ipairs(self.addto.children) do
        if child:includes(FlippedRainPiece) then number = number + 1 end
    end
    return number
end

function FlippedRain:addOverlay()
    local overlay = self.addto:addChild(FlippedRainOverlay(self.type, self))
    table.insert(Game.stage.overlay, {self, overlay})
    return overlay
end

return FlippedRain