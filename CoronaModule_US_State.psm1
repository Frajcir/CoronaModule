
function Get-CoronaStateInfo {
    <#
    .SYNOPSIS
        Get general details about state specific Corona information resources
    .DESCRIPTION
        Get general details about state specific Corona information resources
    .EXAMPLE
        PS C:\> Get-CoronaStateInfo
        Get state info for all states
    .EXAMPLE
        PS C:\> Get-CoronaStateInfo -StateAbbreviation CA
        Get state info for California only
    .OUTPUTS
        state - State or territory postal code abbreviation.
        name - Full state or territory name.
        fips - Federal Information Processing Standard state code
        covid19Site - Webpage dedicated to making results available to the public. More likely to contain numbers. We make regular screenshots of this URL.
        covid19SiteSecondary - Typically more informational.
        twitter - Twitter for the State Health Department
        pui - Person Under Investigation; it is meant to capture positive, negative, and pending test results.
        pum - Person Under Monitoring; we don’t collect these numbers as they are reported far less consistently across states
        notes - Notes about the information available and how we collect or record it.
    .NOTES
        Thanks covidtracking.com: https://covidtracking.com/api/states/info
    #>

    param (
        [Parameter(Mandatory=$false)]
        [ValidateScript({Confirm-StateAbbreviation $_})]
        [string]
        $StateAbbreviation
    )

    $StatesInfo = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/states/info"

    #Filter data if State abbreviation was specified
    if ($StateAbbreviation) {
        $SpecificStateInfo = $StatesInfo | Where-Object -Property state -EQ $StateAbbreviation
        $SpecificStateInfo
    }
    else {
        $StatesInfo
    }
}

function Get-CoronaStateData {
    <#
    .SYNOPSIS
        Get US State Corona virus tracking data from covidtracking.com
    .DESCRIPTION
        Get 'States Current Values' or 'States Historical Data' from covidtracking.com. Use the -Historical switch to get daily data values. Use -StateAbbreviation to get data only for a specific state.
    .EXAMPLE
        PS C:\> Get-CoronaStateData
        Get current Corona virus state data for all states.
    .EXAMPLE
        PS C:\> Get-CoronaStateData -StateAbbreviation CA
        Get current Corona virus state data for the state of California
    .EXAMPLE
        PS C:\> Get-CoronaStateData -Historical
        Get historical (daily) Corona virus data per state for all states
    .EXAMPLE
        PS C:/> Get-CoronaStateData
        Get current Corona virus state data for all states
    .OUTPUTS
        Properties returned for current state data (without -Historical switch):
            state - State or territory postal code abbreviation.
            positive - Total cumulative positive test results.
            positiveScore - +1 for reporting positives reliably.
            negative - Total cumulative negative test results.
            negativeScore - +1 for reporting negatives sometimes.
            negativeRegularScore - +1 for reporting negatives reliably.
            commercialScore - +1 for reporting all commercial tests.
            score - Total reporting quality score.
            grade - Letter grade based on score.
            totalTestResults - Calculated value (positive + negative) of total test results.
            hospitalized - Total cumulative number of people hospitalized.
            death - Total cumulative number of people that have died.
            dateModified - ISO 8601 date of the time the data was last updated by the state.
            dateChecked - ISO 8601 date of the time we last visited their website
            total - DEPRECATED Will be removed in the future. (positive + negative + pending). Pending has been an unstable value and should not count in any totals.

        Properties returned for historical (daily) state data (with -Historical switch):
            state - State or territory postal code abbreviation.
            positive - Total cumulative positive test results.
            positiveIncrease - Increase from the day before.
            negative - Total cumulative negative test results.
            negativeIncrease - Increase from the day before.
            pending - Tests that have been submitted to a lab but no results have been reported yet.
            totalTestResults - Calculated value (positive + negative) of total test results.
            totalTestResultsIncrease - Increase from the day before.
            hospitalized - Total cumulative number of people hospitalized.
            hospitalizedIncrease - Increase from the day before.
            death - Total cumulative number of people that have died.
            deathIncrease - Increase from the day before.
            dateChecked - ISO 8601 date of the time we saved visited their website
            total - DEPRECATED Will be removed in the future. (positive + negative + pending). Pending has been an unstable value and should not count in any totals.
    .NOTES
        Thank you covidtracking.com
        https://covidtracking.com/api/states"
        https://covidtracking.com/api/states/daily
    #>

    param (
        [Parameter(Mandatory=$false)]
        [ValidateScript({Confirm-StateAbbreviation $_})]
        [string]
        $StateAbbreviation,
        [Parameter(Mandatory=$false)]
        [switch]
        $Historical
    )

    #Get states data from covidtracking.com
    if (-not $Historical) {
        $StatesData = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/states"
    }
    else {
        $StatesData = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/states/daily"
    }
    
    #Filter data if State abbreviation was specified
    if ($StateAbbreviation) {
        $SpecificStateData = $StatesData | Where-Object -Property state -EQ $StateAbbreviation
        $SpecificStateData
    }
    else {
        $StatesData
    }
}

function Get-CoronaStateDeathRate {
    <#
    .SYNOPSIS
        Get Corona death rate per state
    .DESCRIPTION
        Calculate the death rate using data from covidtracking.com.
        deathrate = (death/positive)*100
    .EXAMPLE
        PS C:\> Get-CoronaStateDeathRate
        Get Corona virus death rate for all states using current data
    .EXAMPLE
        PS C:\> Get-CoronaStateDeathRate -StateAbbreviation CA
        Get Corona virus death rate for the state of California
    .EXAMPLE
        PS C:\> Get-CoronaStateDeathRate -Historical
        Get historical Corona virus death rate for all states
    .EXAMPLE
        PS C:\> Get-CoronaStateDeathRate -StateAbbreviation CA -Historical
        Get historical Corona virus death rate for the state of California
    .OUTPUTS
            state
            date
            positive - Total cumulative positive test results.
            death - Total cumulative number of people that have died.
            deathrate - (death/positive)*100
    #>
    param (
        [Parameter(Mandatory=$false)]
        [ValidateScript({Confirm-StateAbbreviation $_})]
        [string]
        $StateAbbreviation,
        [Parameter(Mandatory=$false)]
        [switch]
        $Historical
    )
    
    $DeathRateData = New-Object -TypeName System.Collections.ArrayList
    #Get state data using Get-CoronaStateData
    if (-not $Historical) {
        if ($StateAbbreviation) {
            $StatesData = Get-CoronaStateData -StateAbbreviation $StateAbbreviation
        }
        else {
            $StatesData = Get-CoronaStateData
        }
    }
    else {
        if ($StateAbbreviation) {
            $StatesData = Get-CoronaStateData -StateAbbreviation $StateAbbreviation -Historical
        }
        else {
            $StatesData = Get-CoronaStateData -Historical
        }
    }

    #Calculate death rate (positive/death)
    foreach ($item in $StatesData) {
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
            state=$item.state
            date=$date
            positive=$TotalPositive
            death=$TotalDeath
            deathrate=$DeathRate
        }

        $DeathRateData.Add($obj) | Out-Null
    }

    $DeathRateData
}

function Get-CoronaStateTrackerUrl {
    <#
    .SYNOPSIS
        Get tracking website URL for state Corona information resources
    .DESCRIPTION
        Get tracking website URL for state Corona information resources
    .EXAMPLE
        PS C:\> Get-CoronaStateTrackerUrl
        Get state info for all states
    .EXAMPLE
        PS C:\> Get-CoronaStateTrackerUrl -StateAbbreviation CA
        Get state info for California only
    .OUTPUTS
        name: State Name
        stateId: State or territory postal code abbreviation.
        url: String
        kind: String
        filter: String
        headers: Object
        navigate: String
        options: Object
        ssl_no_verify: Boolean
    .NOTES
        Thanks covidtracking.com: https://covidtracking.com/api/urls
    #>

    param (
        [Parameter(Mandatory=$false)]
        [ValidateScript({Confirm-StateAbbreviation $_})]
        [string]
        $StateAbbreviation
    )

    $StatesUrls = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/urls"

    #Filter data if State abbreviation was specified
    if ($StateAbbreviation) {
        $SpecificStateUrl = $StatesUrls | Where-Object -Property state -EQ $StateAbbreviation
        $SpecificStateUrl
    }
    else {
        $StatesUrls
    }
}

function Get-CoronaStateWebsiteScreenshot {
    <#
    .SYNOPSIS
        Get URL to screen shot of state Corona virus tracking websites.
    .DESCRIPTION
        Get the URL of the covidtracking.com screen shot of state Corona virus tracking websites.
    .EXAMPLE
        PS C:\> Get-CoronaStateWebsiteScreenshot
        Get list of daily screenshots for all states
    #>
    
    $StateWebsiteScreenshot = Invoke-RestMethod -Method Get -Uri "https://covidtracking.com/api/screenshots"
    $StateWebsiteScreenshot
}

function Confirm-StateAbbreviation {
    param (
        [Parameter(Mandatory=$true)]
        [ValidatePattern("[A-Z][A-Z]")]
        [string]
        $StateAbbreviation
    )

    # validate state abreviation code against COVID tracking project current state data
    $StateData = Invoke-RestMethod -Uri "https://covidtracking.com/api/states"
    if ($StateData.state -contains $StateAbbreviation) {
        $true
    }
    else {
        $false
    }
}