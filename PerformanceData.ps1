##################################################################################################################
#                                                                                                                #
# PerformanceData.ps1                                                                                            #
#                                                                                                                #
# [機能概要]                                                                                                     #
# 指定時間のマシンのパフォーマンスをcsvに出力                                                                    #
#                                                                                                                #
# [使用方法]                                                                                                     #
# 0:00(開始時間) - 23:59(終了時間)のパフォーマンスを取得する場合、                                               #
# PerformanceData.batを0:00(開始時間)以降に実行する                                                              #
#                                                                                                                #
#                                                                                                                #
##################################################################################################################

$startTime = "0:00"
$endTime = "23:59"

# 今日の日付を基準に開始時間と終了時間を計算
$start = (Get-Date -Format "yyyy/MM/dd HH:mm:ss" $startTime)
$end = (Get-Date -Format "yyyy/MM/dd HH:mm:ss" $endTime)

# 次の日を跨ぐ場合
if ($end -lt $start) {
    $end = $end.AddDays(1)
}

# ログファイルパス
$logFile = "C:\PerformanceData_$(Get-Date -Format "yyyyMMddHHmmss").csv"

# ヘッダ
if (-not(Test-Path $logFile)) {
    "`"TimeStamp`",`"Counter`",`"Value`"" | Out-File -FilePath $logFile -Encoding utf8
}

# 10秒間隔でパフォーマンスデータを収集
while ($true) {
    $now = (Get-Date -Format "yyyy/MM/dd HH:mm:ss")
    if ($now -ge $start -and $now -lt $end) {
        $counters = Get-Counter '\Processor(_Total)\% Processor Time',      # CPU使用率
                                '\Memory\Available MBytes',                 # メモリ使用率
                                '\PhysicalDisk(_Total)\Disk Transfers/sec', # ディスクI/O
                                '\Network Interface(*)\Bytes Total/sec'     # ネットワークトラフィック
        foreach ($sample in $counters.CounterSamples) {
            "`"$($sample.Timestamp)`",`"$($sample.Path)`",`"$($sample.CookedValue)`"" | 
            Out-File -FilePath $logFile -Append -Encoding utf8
        }
        Start-Sleep 10
    }
    elseif ($now -ge $end) {
        # ログ収集完了
        break
    }
    else {
        # 日付指定に誤りあり
    }
}