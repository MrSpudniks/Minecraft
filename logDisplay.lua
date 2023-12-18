--pastebin BjBiMEPf
monitor = peripheral.wrap("right")
height = 2
textScale = 0.5
monitor.setTextScale(textScale)
verticalHeight = height * (1 / textScale) * 7 - (2 * (1 / textScale))
lastLength = 0
 
 
function monitorWrite(msg)
    monitor.write(string.format("%s                                                ", msg))
end
 
 
 
while true do
    file = fs.open("disk/log.txt", "r")
    lines = {}
    
    
    
    for line in file.readLine do
        table.insert(lines, line)
    end
    
    
    
    if #lines < lastLength then
        shell.run("disk/clearMonitor.lua")
    end
    lastLength = #lines
    
    
    
    if #lines > verticalHeight then
        for i = 0, verticalHeight do
            monitor.setCursorPos(1, verticalHeight - i)
            monitorWrite(lines[#lines - i])
        end
    else
        for i = 1, #lines do
            monitor.setCursorPos(1, i)
            monitorWrite(lines[i])
        end
    end
    
    file.close()
    sleep(1)
end