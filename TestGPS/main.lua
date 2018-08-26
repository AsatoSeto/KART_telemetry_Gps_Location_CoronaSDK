display.newText("latitude: ", 100,50, native.systemFont, 40)   --объявление статичных текстовых полей
display.newText("longitude: ", 115,100, native.systemFont, 40)
display.newText("altitude: ", 100,150, native.systemFont, 40)


local latitude = display.newText( "-", 350, 50, native.systemFont, 40 ) --объявление динамических текстовых полей
local longitude = display.newText( "-", 350, 100, native.systemFont, 40 )
local altitude = display.newText( "-", 300, 150, native.systemFont, 40 )
local time = display.newText( "-", 170, 200, native.systemFont, 40 )
local filename = display.newText("-" , display.contentCenterX,400,native.systemFont, 40 )


local check_time = 0
local check_temp = 0

local enableWrite = false
local t = ''
local ti = ''
local fileName=''
local btn1_click = false
local btn2_click = false

flashCircle = display.newCircle(display.contentCenterX, display.contentCenterY, 50)   --генерация круга

local widget = require( "widget" ) --объявление виджета

local function date()
	if (enableWrite) then
		t = os.date('*t')
    	ti = tostring(t.hour) .. tostring(t.min) .. tostring(t.sec).. tostring(t.month) .. tostring(t.day) 
		fileName = ti .. "GPSTrackData.csv"
		file_write(fileName)
		enableWrite=false
	else
		file_write(fileName)
	end
end
 
local function handleButtonEvent( event ) -- обработчик кнопки 1
	if (btn1_click==false) then
	    if ( "ended" == event.phase ) then
			enableWrite = true
			date()
			btn1_click = true
			btn2_click = false
	    end
	end
end
 
-- Create the widget
local button1 = widget.newButton(  -- генерация кнопки 1
    {
        left = 50,
        top = 300,
        id = "button1",
        label = "Start write",
        onEvent = handleButtonEvent
    }
)
button1:scale(2,2) --размер кнопки

local function handleButton2Event( event )-- обработчик кнопки 2
   if (btn2_click == false) then
    	if ( "ended" == event.phase ) then
    		timer.cancel(write_time)
    		filename.text = ""
    		btn2_click = true
    		btn1_click = false
    	end
	end
end
 
-- Create the widget
local button2 = widget.newButton(			 -- генерация кнопки 2
    {
        left = 300,
        top = 300,
        id = "button1",
        label = "Stop write",
        onEvent = handleButton2Event
    }
)
button2:scale(2,2)

local  locationHandler = function ( event )							--обработчик датчика GPS 		
	if ( event.errorCode ) then
		native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
	  	print( "Location error: " .. tostring( event.errorMessage ) )
	  	flashCircle:setFillColor(255/255,0/255,0/255)
	else    	
		local latitudeText = string.format( '%.10f', event.latitude )
		latitude.text = latitudeText
				 
		local longitudeText = string.format( '%.10f', event.longitude )
		longitude.text = longitudeText
				 
		local altitudeText = string.format( '%.3f', event.altitude )
		altitude.text = altitudeText	

		local timeText = string.format( '%.3f', event.time )
	    time.text = timeText
	end
end

function file_write(fileName)														--функция записи в файл
	local path = system.pathForFile(fileName,system.DocumentsDirectory)
	local file, errorString = io.open(path,"a")
	filename.text = fileName
	if not file then
		print ("File error:" .. errorString)
	else
		flashCircle:setFillColor(0/255,255/255,0/255)
		file:write(latitude.text)
		file:write(", ")
		file:write(longitude.text)
		file:write(", ")
		file:write(altitude.text)
		file:write(", ")
		file:write(time.text)
		--file:write(string.format('%.3f',event.time))
		file:write("\n")
		io.close(file)
	 	file = nil
	 	write_time = timer.performWithDelay( 500, date )
	end      	        	
end

local function isnil(gps_perem)									--функция проверки nil значения показаний GPS
	return gps_perem==nil or gps_perem==''
end

local function check_gps()										--функция проверки есть ли данные с GPS и запуск счётчика времени
	if isnil(tonumber(latitude.text)) then
		flashCircle:setFillColor(255/255,0/255,0/255)
	else
		if(check_time==tonumber(time.text)) then
			flashCircle:setFillColor(255/255,0/255,0/255)
		else
			flashCircle:setFillColor(255/255,255/255,0/255)
		end
	end
	timer.performWithDelay( 1000, check_gps )
end

Runtime:addEventListener( "location", locationHandler )
check_gps()