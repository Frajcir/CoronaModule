
function Get-CoronaUSData {
    <#
    .SYNOPSIS
        Get US cummulative Corona virus tracking data from covidtracking.com
    .DESCRIPTION
        Get 'US Current Values' or 'US Historical Values' from covidtracking.com. Use the -Historical switch to get daily data values.
    .EXAMPLE
        PS C:\> Get-CoronaUSData
        Get current Corona virus country wide data.
    .EXAMPLE
        PS C:\> Get-CoronaUSData -Historical
        Get historical (daily) Corona virus country wide data.
    .OUTPUTS
        Properties returned for cummulative US data to date
            positive - Total cumulative positive test results.
            negative - Total cumulative negative test results.
            totalTestResults - Calculated value (positive + negative) of total test results.
            hospitalized - Total cumulative number of people hospitalized.
            death - Total cumulative number of people that have died.
            posNeg - DEPRECATED Renamed to totalTestResults.
            total - DEPRECATED Will be removed in the future. (positive + negative + pending). Pending has been an unstable value and should not count in any totals.
        Properties returned for historical (daily) state data (with -Historical switch):
            dateChecked - ISO 8601 date of when these values were valid.
            states - Quantity of states and territories that are reporting data.
            positive - Total cumulative positive test results.
            positiveIncrease - Increase from the day before.
            negative - Total cumulative negative test results.
            negativeIncrease - Increase from the day before.
            hospitalized - Total cumulative number of people hospitalized.
            hospitalizedIncrease - Increase from the day before.
            death - Total cumulative number of people that have died.
            deathIncrease - Increase from the day before.
            pending - Tests that have been submitted to a lab but no results have been reported yet.
            totalTestResults - Calculated value (positive + negative) of total test results.
            totalTestResultsIncrease - Increase from the day before.
            posNeg - DEPRECATED Renamed to totalTestResults.
            total - DEPRECATED Will be removed in the future. (positive + negative + pending). Pending has been an unstable value and should not count in any totals.    
        .NOTES
        Thank you covidtracking.com
        https://covidtracking.com/api/us
        https://covidtracking.com/api/us/daily
    #>

    param (
        [Parameter(Mandatory=$false)]
        [switch]
        $Historical
    )

    #Get states data from covidtracking.com
    if (-not $Historical) {
        $USData = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/us"
    }
    else {
        $USData = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/us/daily"
    }
    $USData
}

function Get-CoronaUSDeathRate {
    <#
    .SYNOPSIS
        Get Corona virus death rate for US
    .DESCRIPTION
        Calculate the death rate using data from covidtracking.com.
        deathrate = (death/positive)*100
    .EXAMPLE
        PS C:\> Get-CoronaUSeathRate
        Get Corona virus death rate for all states using current data
    .EXAMPLE
        PS C:\> Get-CoronaUSDeathRate -Historical
        Get historical Corona virus death rate for all states
    .OUTPUTS
            date
            positive - Total cumulative positive test results.
            death - Total cumulative number of people that have died.
            deathrate - (death/positive)*100
    #>
    param (
        [Parameter(Mandatory=$false)]
        [switch]
        $Historical
    )
    
    $DeathRateData = New-Object -TypeName System.Collections.ArrayList
    #Get US data using Get-CoronaUSData
    if (-not $Historical) {
        $USData = Get-CoronaUSData
    }
    else {
        $USData = Get-CoronaUSData -Historical
    }

    #Calculate death rate (positive/death)
    foreach ($item in $USData) {
        #Properties for result object
        $TotalPositive = $item.positive
        $TotalDeath = $item.death
        if ($item.date) {
            $date = $item.date
        }
        else {
            $date = Get-Date -UFormat "%Y%m%d"
        }

        if ( ($TotalPositive -gt 0) -and ($TotalDeath -gt 0) ) {
            $DeathRate = [System.Math]::Round(($TotalDeath/$TotalPositive)*100,2)
        }
        
        $obj = [PSCustomObject]@{
            date=$date
            positive=$TotalPositive
            death=$TotalDeath
            deathrate=$DeathRate
        }

        $DeathRateData.Add($obj) | Out-Null
    }

    $DeathRateData
}

function Get-CoronaUSPressCoverage {
    $USPressCoverage = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/press"
    $USPressCoverage
}