--pastebin 5PQj0BSx
monitor = peripheral.wrap("right")
height = 2
textScale = 0.5
monitor.setTextScale(textScale)
verticalHeight = height * (1 / textScale) * 7 - (2 * (1 / textScale))
lastLength = 0
logLocation = false



function monitorWrite(msg)
    monitor.write(string.format("%s                                                ", msg))
end



function clear_monitor()
    for line = 0, verticalHeight do
        monitor.setCursorPos(1, line)
        monitorWrite("")
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



while true do
    file = fs.open(logLocation, "r")
    lines = {}
    
    for line in file.readLine do
        table.insert(lines, line)
    end
    
    if #lines < lastLength then
        clear_monitor()
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
