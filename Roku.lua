debug = false
json = require('json')
rokuPort = 8060
timerMultiplier = 4
timerCounter = 0
allowConnect = false
isConnected = false

--Creates URL to use through Script
function rokuKeyPress(keyValue, Host, Port)
       return HttpClient.CreateUrl( {
              Host = rokuHostName,
              Query = {}, 
              Port = rokuPort,
              Path = 'keypress/' .. keyValue})    
end

--Turns LED on or off based on successful HTTP Status Code returned
function Response(Table, ReturnCode, Data, Error, Headers)
       url = HttpClient.CreateUrl( {
              Host = rokuHostName,
              Query = {}, 
              Port = rokuPort, })

       if (200 == ReturnCode or ReturnCode == 201) then
              NamedControl.SetPosition("LED #2", 1) 
       else
              NamedControl.SetPosition("LED #2", 0)
       end 
end

--Names of buttons in module
controlNames = { "Arrow Left","Arrow Right","Arrow Up",
                 "Arrow Down","Home","ok","Power",
                 "Previous","Next","Play","Back","Star",
                 "VolumeUp","VolumeDown","Loop"}

--What Roku expects to see
rokuApiValues = {"left","right","up",
                 "down","Home","select",
                 "PowerOff","Rev","Fwd",
                 "Play","Back","Info",
                 "VolumeUp","VolumeDown","InstantReplay"}

function TimerClick()  
       rokuHostName = (NamedControl.GetText("IP"))   
       offlineConnectButton = NamedControl.GetValue("ButtonOfflineConnect")
 
       --Establishes if allowed to connect
       if offlineConnectButton == 1 and Device.Offline then
              allowConnect = true
              NamedControl.SetPosition("OfflineConnect", 1)
       elseif Device.Offline == false then
              allowConnect = true
              NamedControl.SetPosition("OfflineConnect", 0)
       else
              allowConnect = false
              NamedControl.SetPosition("OfflineConnect", 0)
       end

       if allowConnect then
              controlValues = {} 

              --Adds the key and position of the controlNames table to the controlValues table
              for k,v in ipairs(controlNames) do
                     table.insert(controlValues, k, NamedControl.GetPosition(v))
              end
       
              --checks position of NamedControl and uploads rokuApiValues key
              for k,v in ipairs(controlValues) do
                     if v == 1 then
                            NewUrl = rokuKeyPress(rokuApiValues[k])
                            HttpClient.Upload({ Url = NewUrl }) 

                            if debug then
                                   print(NewUrl) 
                            end

                            NamedControl.SetPosition(controlNames[k], 0)
                     end
              end
       end
   
       timerCounter = timerCounter + 1
       --checks online status of composer at a slower rate then the TimerClick
       if timerCounter >= timerMultiplier then
              HttpClient.Download({ Url = url, EventHandler = Response  })
              if Device.Offline == true then
                     NamedControl.SetPosition("LED #1", 0)
              else
                     NamedControl.SetPosition("LED #1", 1)
              end
       
              timerCounter = 0
       end
end

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.5)