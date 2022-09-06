function Initialize()
	coinID = tonumber(SKIN:GetVariable('CoinID'))
	coinSymbol = SKIN:GetVariable('CoinSymbol')
	currency = SKIN:GetVariable('Currency')
	url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?convert=' .. currency
	
	-- If coin ID set use coin ID to fetch data instead of the SYMBOL
	if not coinID then
		url = url .. '&symbol=' .. coinSymbol
	else
		url = url .. '&id=' .. coinID
	end
	
	SKIN:Bang('!SetOption', 'MeasureCoinData', 'URL', url)
	SKIN:Bang('!CommandMeasure', 'MeasureCoinData', 'Update')
end

function Round(num)
    if num == '' then
        return num
    end
    
    num = tonumber(num)
    
    local idp = 2
    if num < 1 then
        idp = 6
    end
	
	if num < 0.00001 then
        idp = 8
    end
	
	return string.format('%.' .. idp .. 'f', num)
end

function RoundWithPrecision(num, idp)
	if num == '' then
        return num
    end
    
    num = tonumber(num)

	return string.format('%.' .. idp .. 'f', num)
end

function RoundPercent(num)
    if num == '' then
        return num
    end
    
    num = tonumber(num)
        
	local mult = 10 ^ (2 or 0)
	if num >= 0 then
		return math.floor(num * mult + 0.5) / mult
	else
		return math.ceil(num * mult - 0.5) / mult
	end
end

function CheckVersion(current, latest)
    local MeasureVersion = SKIN:GetMeasure('MeasureVersion')
    
    current = tonumber(SKIN:GetVariable('Version'))
    latest = tonumber(MeasureVersion:GetStringValue())
    
    local MeterDonateIcon = SKIN:GetMeter('MeterDonateIcon')
    local MeterUpgradeIcon = SKIN:GetMeter('MeterUpgradeIcon')
    if latest > current then
        MeterUpgradeIcon:Show()
    else
        MeterDonateIcon:Show()
    end
end

function OnRequestParsed()
	local MeasureCoinLastUpdated = SKIN:GetMeasure('MeasureCoinLastUpdated')
	local date = MeasureCoinLastUpdated:GetStringValue()
	local coinSymbol = SKIN:GetMeasure('MeasureCoinSymbol'):GetStringValue()
	
	-- Set icon based on the symbol
	SKIN:Bang('!SetOption', 'MeterIcon', 'ImageName', '#@#icons/' .. coinSymbol .. '.png')

	-- Set formatted date
	SKIN:Bang('!SetOption', 'MeasureCoinLastUpdatedFormatted', 'String', FormatDate(date))
	
	-- Round numbers
	local MeasureCoinPrice = SKIN:GetMeasure('MeasureCoinPrice')
	SKIN:Bang('!SetOption', 'MeasureCoinPriceRounded', 'String', Round(MeasureCoinPrice:GetStringValue()))
	
	local MeasureCoinChange1H = SKIN:GetMeasure('MeasureCoinChange1H')
	SKIN:Bang('!SetOption', 'MeasureCoinChange1HRounded', 'String', RoundPercent(MeasureCoinChange1H:GetStringValue()))
	
	local MeasureCoinChange1D = SKIN:GetMeasure('MeasureCoinChange1D')
	SKIN:Bang('!SetOption', 'MeasureCoinChange1DRounded', 'String', RoundPercent(MeasureCoinChange1D:GetStringValue()))
	
	local MeasureCoinChange7D = SKIN:GetMeasure('MeasureCoinChange7D')
	SKIN:Bang('!SetOption', 'MeasureCoinChange7DRounded', 'String', RoundPercent(MeasureCoinChange7D:GetStringValue()))

	assetsOwned = tonumber(SKIN:GetVariable('AssetsOwned'))
	assetsValue = tonumber(SKIN:GetVariable('AssetsValue'))

	if assetsOwned then
		currency = SKIN:GetVariable('Currency')

		-- Set assets owned and total current value
		SKIN:Bang('!SetOption', 'MeasureAssetsOwned', 'String', assetsOwned .. ' ' .. coinSymbol .. ' | ' .. currency .. ' ' .. Round(assetsOwned * tonumber(MeasureCoinPrice:GetStringValue())))
		SKIN:Bang('!ShowMeter', 'MeterAssetsOwned')

		-- If assets value is set also show profit percent
		if assetsValue then
			assetsProfit = assetsOwned * tonumber(MeasureCoinPrice:GetStringValue()) - assetsValue
			assetsIncrease = (assetsProfit / assetsValue) * 100
		
			SKIN:Bang('!SetOption', 'MeasureAssetsIncrease', 'String', currency .. ' ' .. RoundWithPrecision(assetsProfit, 2) .. ' | ' .. RoundPercent(assetsIncrease) .. '%')
			SKIN:Bang('!SetOption', 'MeterAssetsIncrease', 'FontColor', '5eb160')
			if assetsProfit < 0 then
				SKIN:Bang('!SetOption', 'MeterAssetsIncrease', 'FontColor', 'ff4b48')
			end
			SKIN:Bang('!ShowMeter', 'MeterAssetsIncrease')
		end
	end
end

function GetTimezoneDiff()
	localTime = os.time(os.date('*t'))
	utcTime = os.time(os.date('!*t'))
	
	return utcTime - localTime
end
  

function FormatDate(date)
	local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
	local runyear, runmonth, runday, runhour, runminute, runseconds = date:match(pattern)
	local timestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds}) - GetTimezoneDiff()
	
	return os.date('%c', timestamp)
end