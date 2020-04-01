# CoronaModule

Access the data available from The COVID Tracking Project API (https://covidtracking.com/api/)

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

# Examples

Get current Corona virus state data for all states.

  PS C:\>Get-CoronaStateData | Format-Table state,positive,negative,death

  state positive negative death
  ----- -------- -------- -----
  AK         133     4470     3
  AL         999     6298    13
  AR         564     6869     8
  AZ        1289    18082    24
  CA        8520    21772   180
  CO        2966    13883    69
  CT        3128    13029    69
  DC         499     3262     9
  DE         319     3696    10
  FL        6741    56644    85
  GA        4117    12253   125
  ...

Get historical (daily) Corona virus state data for the state of California
  PS C:\>Get-CoronaStateData -StateAbbreviation CA -Historical | Format-Table date,state,positive,negative,death

      date state positive negative death
      ---- ----- -------- -------- -----
  20200331 CA        7482    21772   153
  20200330 CA        6447    20549   133
  20200329 CA        5708    20549   123
  20200328 CA        4643    20549   101
  20200327 CA        3879    17380    78
  20200326 CA        3006    17380    65
  20200325 CA        2355    15921    53
  20200324 CA        2102    13452    40
  20200323 CA        1733    12567    27
  20200322 CA        1536    11304    27
  20200321 CA        1279    11249    24
  ...

Get historical Corona virus death rate for all states

  PS C:\>Get-CoronaUSDeathRate -Historical

      date positive death deathrate
      ---- -------- ----- ---------
  20200331   184770  3746      2.03
  20200330   160530  2939      1.83
  20200329   139061  2428      1.75
  20200328   118234  1965      1.66
  20200327    99413  1530      1.54
  20200326    80735  1163      1.44
  20200325    63928   900      1.41
  20200324    51954   675       1.3
  ...
