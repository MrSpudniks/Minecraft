--pastebin MDZrRag9
r = peripheral.wrap("back")
m = peripheral.wrap("right")
m.setTextScale(1)
cooldown = 0
startSide = "bottom"
stopSide = "left"
 

 
function color(value, mult)
    if value <= 0.01 then
        m.setTextColor(colors.red)
        danger = danger + 100
    elseif value < 0.1 then
        m.setTextColor(colors.red)
        danger = danger + 70 * mult
        
    elseif value < 0.25 then
        m.setTextColor(colors.orange)
        danger = danger + 45 * mult
        
    elseif value < 0.5 then
        m.setTextColor(colors.yellow)
        danger = danger + 15 * mult
        
    else
        m.setTextColor(colors.green)
        
    end
end
 
 
 
function clear()
    for i = 1, 12, 1 do
        m.setCursorPos(1,i)
        m.write("                    ")
    end
end
 
 
 
 
 
while true do
    danger = 0
    
    coolant = r.getCoolantFilledPercentage()
    color(coolant,1.5)
    m.setCursorPos(1,1)    
    m.write(string.format("coolant: %.3f        ", coolant))
    
    fuel = r.getFuelFilledPercentage()
    m.setTextColor(colors.white)
    m.setCursorPos(1,2)
    m.write(string.format("fuel: %.3f        ", fuel))
    
    waste = r.getWasteFilledPercentage()
    color(1 - waste,1)    
    m.setCursorPos(1,3)    
    m.write(string.format("waste: %.3f        ", waste))
    
    steam = r.getHeatedCoolantFilledPercentage()
    color(1 - steam,0.75)
    m.setCursorPos(1,4)
    m.write(string.format("steam: %.3f        ", steam))
    
    heat = r.getTemperature()
    m.setCursorPos(1,6)
    color(1 - (heat/1000),1.5)
    m.write(string.format("temp: %.0f        ", heat))
    
    m.setCursorPos(1,12)
    if danger >= 100 then
        if r.getStatus() then
            r.scram()
        end
        cooldown = 200
        
    elseif danger >= 60 then
        m.setTextColor(colors.red)
        m.write("DANGER            ")
        rs.setOutput("top", true)
        
    elseif danger >= 30 then
        m.setTextColor(colours.orange)
        m.write("Deficient          ")
    
    elseif danger >= 1 then
         m.setTextColor(colors.yellow)
         m.write("Sub Optimal       ")
    
    else
         m.setTextColor(colors.green)
         m.write("Optimal           ")
           
    end
    
    if cooldown > 0 then
        cooldown = cooldown - 1
        if r.getStatus() then
            r.scram()
        end
        m.setCursorPos(1,11)
        m.setTextColor(colors.red)
        m.write(cooldown)
        
    else
        
        if rs.getInput(startSide) and not r.getStatus() then
            r.activate()
            
        end
        
        if rs.getInput(stopSide) and r.getStatus() then
            r.scram()
        end
        
    end
            
    m.setCursorPos(16,12)
    m.write(danger)
    --clear()
end