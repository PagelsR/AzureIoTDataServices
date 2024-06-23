# Define start locations
$startLocations = @(
    @{ID="Asd"; Name="Amsterdam Centraal"; Latitude=52.379189; Longitude=4.899431},
    @{ID="Asdz"; Name="Amsterdam Zuid"; Latitude=52.338602; Longitude=4.871978},
    @{ID="Ams"; Name="Amsterdam Amstel"; Latitude=52.346587; Longitude=4.918684},
    @{ID="Rtd"; Name="Rotterdam Centraal"; Latitude=51.922500; Longitude=4.467167},
    @{ID="Rtb"; Name="Rotterdam Blaak"; Latitude=51.920582; Longitude=4.486082},
    @{ID="Ut"; Name="Utrecht Centraal"; Latitude=52.089444; Longitude=5.110278},
    @{ID="Uto"; Name="Utrecht Overvecht"; Latitude=52.113333; Longitude=5.111111},
    @{ID="Gvc"; Name="The Hague Centraal"; Latitude=52.084167; Longitude=4.324722},
    @{ID="GV"; Name="The Hague Hollands Spoor"; Latitude=52.070833; Longitude=4.322222},
    @{ID="Nm"; Name="Nijmegen Station"; Latitude=51.841111; Longitude=5.854167},
    @{ID="Ah"; Name="Arnhem Centraal"; Latitude=51.985000; Longitude=5.898611}
)

# Define potential end locations (could be the same as start locations for simplicity)
$endLocations = $startLocations.Clone()

# Initialize an empty array for the data rows
$dataRows = @()

# Convert date range to ticks for random generation
$startDateTicks = (Get-Date "2024-10-01").Ticks
$endDateTicks = (Get-Date "2024-10-05").Ticks

# Generate 50 rows of data
1..4000 | ForEach-Object {
    $start = $startLocations | Get-Random
    $end = $endLocations | Where-Object {$_.ID -ne $start.ID} | Get-Random
    $bikeId = Get-Random -Minimum 1000 -Maximum 1999
    
    # Generate random start and stop times within the date range
    $randomStartTicks = Get-Random -Minimum $startDateTicks -Maximum $endDateTicks
    $randomStopTicks = Get-Random -Minimum $randomStartTicks -Maximum $endDateTicks

    $startTime = [datetime]::new($randomStartTicks)
    $stopTime = [datetime]::new($randomStopTicks)

    $row = New-Object PSObject -Property @{
        startStationID = $start.ID
        startStationName = $start.Name
        startstationlatitude = $start.Latitude
        startstationlongitude = $start.Longitude
        endstationid = $end.ID
        endstationname = $end.Name
        endstationlatitude = $end.Latitude
        endstationlongitude = $end.Longitude
        bikeid = $bikeId
        starttime = $startTime.ToString("MM-dd-yyyy HH:mm:ss")
        stoptime = $stopTime.ToString("MM-dd-yyyy HH:mm:ss")
    }
    
    $dataRows += $row
}

# Output to a CSV file
$dataRows | Select-Object starttime,stoptime,startStationID, startStationName, startstationlatitude, startstationlongitude, endstationid, endstationname, endstationlatitude, endstationlongitude, bikeid | Export-Csv -Path "OV-fietsRentalLocations.csv" -NoTypeInformation -Encoding UTF8