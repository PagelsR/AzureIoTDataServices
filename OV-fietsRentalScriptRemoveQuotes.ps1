# Export data to CSV with quotes (PowerShell will automatically add quotes)
$dataRows | Select-Object starttime, stoptime, startStationID, startStationName, startstationlatitude, startstationlongitude, endstationid, endstationname, endstationlatitude, endstationlongitude, bikeid | Export-Csv -Path "OV-fietsRentalLocations.csv" -NoTypeInformation -Encoding UTF8

# Read the CSV content, replace quotes, and write back to the file
(Get-Content -Path "OV-fietsRentalLocations.csv" -Raw).Replace('"', '') | Set-Content -Path "OV-fietsRentalLocations.csv"