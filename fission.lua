--pastebin x0QBbWUt
r = peripheral.wrap("fissionReactorLogicAdapter_1") --fission reactor logic port
m = peripheral.wrap("right") --2x2 monitor
m.setTextScale(1)
cooldown = 0
startSide = "front"
stopSide = "top"
lastDangerLevel = 0
logLocation = false

 
 
function log(msg)
    file = fs.open(logLocation, "a")
    file.writeLine(string.format("%s: %s", os.date("%H:%M %d.%m.%Y"), msg))
    file.close()
end
 
 
 
while logLocation == false do
    sleep(1)
    for i = 0, 20 do
    
        if peripheral.wrap(string.format("drive_%d", i)) ~= nil then
            
            diskDrive = peripheral.wrap(string.format("drive_%d", i))
            
            
            
            if diskDrive.getDiskLabel() == "log" then
            
                mountPath = diskDrive.getMountPath()
            
                logLocation = string.format("%s/log.txt", mountPath)
        
            end
        end
    end

end
 
 
 
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
 
 
 
log("booted")
 
 
 
function clear()
    for i = 1, 12, 1 do
        m.setCursorPos(1, i)
        m.write("                                           ")
    end
end
 
 
 
 
 
while true do
    danger = 0
    
    coolant = r.getCoolantFilledPercentage()
    color(coolant, 1.5)
    m.setCursorPos(1, 1)    
    m.write(string.format("coolant: %.3f        ", coolant))
    
    fuel = r.getFuelFilledPercentage()
    m.setTextColor(colors.white)
    m.setCursorPos(1, 2)
    m.write(string.format("fuel:    %.3f        ", fuel))
    
    waste = r.getWasteFilledPercentage()
    color(1 - waste, 1)    
    m.setCursorPos(1, 3)    
    m.write(string.format("waste:   %.3f        ", waste))
    
    steam = r.getHeatedCoolantFilledPercentage()
    color(1 - steam, 0.75)
    m.setCursorPos(1, 4)
    m.write(string.format("steam:   %.3f        ", steam))
    
    heat = r.getTemperature()
    m.setCursorPos(1,6)
    color(1 - (heat/1000), 1.5)
    m.write(string.format("temp:    %.0f        ", heat))
    
    m.setCursorPos(1, 12)
    if danger >= 100 then
        if r.getStatus() then
            r.scram()
   
            log("automatic scram")
            log(string.format("coolant: %f", coolant))
            log(string.format("steam:   %f", steam))
            log(string.format("waste:   %f", waste))
            log(string.format("temp:    %d", heat))
        end
  
        cooldown = 200
  
    elseif danger >= 60 then
        m.setTextColor(colors.red)
        m.write("DANGER            ")
        --rs.setOutput("top", true) --alarm
        if lastDangerLevel < danger then
            log(string.format("%d  danger", danger))
        end
        
    elseif danger >= 30 then
        m.setTextColor(colours.orange)
        m.write("Deficient          ")
        if lastDangerLevel < danger then
            log(danger)
        end
    
    elseif danger >= 1 then
         m.setTextColor(colors.yellow)
         m.write("Sub Optimal       ")
         if lastDangerLevel < danger then
             log(danger)
         end
    
    else
         m.setTextColor(colors.green)
         m.write("Optimal           ")
           
    end
    
    lastDangerLevel = danger
            
    if cooldown > 0 then
        cooldown = cooldown - 1
        if r.getStatus() then
            r.scram()
        end
        m.setCursorPos(1,11)
        m.setTextColor(colors.red)
        m.write(cooldown)
        
    else
        m.setCursorPos(1, 11)
        m.write("                ")
        
        if rs.getInput(startSide) and not r.getStatus() then
            r.activate()
            log("activation")
            
        end
        
        if rs.getInput(stopSide) and r.getStatus() then
            r.scram()
            log("manual scram")
            
        end
        
    end
            
    m.setCursorPos(16, 12)
    m.write(danger)
    --clear()
end
