# CoronaModule

A script based PowerShell module to access the data available from The COVID Tracking Project API (https://covidtracking.com/api/)

# Install
Install-Module -Name CoronaModule

# Commands
Get-CoronaStateData

Get-CoronaStateInfo

Get-CoronaStateTrackerUrl

Get-CoronaStateDeathRate

Get-CoronaStateWebsiteScreenshot

Get-CoronaUSData

Get-CoronaUSDeathRate

Get-CoronaUSPressCoverage


# Command Usage Examples

Get current Corona virus state data for all states

PS /> Get-CoronaStateData | Format-Table state,positive,negative,death


Get historical (daily) Corona virus state data for the state of California

PS /> Get-CoronaStateData -StateAbbreviation CA -Historical | Format-Table date,state,positive,negative,death


Get historical Corona virus death rate for all states

PS /> Get-CoronaUSDeathRate -Historical


