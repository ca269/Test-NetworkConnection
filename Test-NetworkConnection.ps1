    #Ping Test Analyzer, written by ca269.  This test will send the requested amount of "Pings" (at 1 second intervals) to the site of your choice, 
    #then record the round trip time.  The Data will be displayed as a line graph, and  you'll have the option of exporting it to a PNG file

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization
    Add-Type -AssemblyName PresentationCore,PresentationFramework

    #Window to display current progress
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text ='In progress...'
        $progressForm.Width = 500
        $progressForm.Height = 250
        $progressLabel = New-Object System.Windows.Forms.Label
        $progressLabel.Location  = New-Object System.Drawing.Point(0,10)
        $progressLabel.AutoSize = $true
        $progressLabel.Font = New-Object System.Drawing.Font("Lucida Console",42,[System.Drawing.FontStyle]::Regular)
        $progressForm.Controls.Add($progressLabel)

    #Main Window
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Ping Test Analyzer'
        $form.Size = New-Object System.Drawing.Size(500,500)
        $form.StartPosition = 'CenterScreen'

        $OKButton1 = New-Object System.Windows.Forms.Button
        $OKButton1.Location = New-Object System.Drawing.Point(75,420)
        $OKButton1.Size = New-Object System.Drawing.Size(75,23)
        $OKButton1.Text = 'OK'
        $OKButton1.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $OKButton1
        $form.Controls.Add($OKButton1)

        $CancelButton1 = New-Object System.Windows.Forms.Button
        $CancelButton1.Location = New-Object System.Drawing.Point(150,420)
        $CancelButton1.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton1.Text = 'Cancel'
        $CancelButton1.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $CancelButton1
        $form.Controls.Add($CancelButton1)

    #Program Description to display to user
        $label1 = New-Object System.Windows.Forms.Label
        $label1.Location = New-Object System.Drawing.Point(10,20)
        $label1.Size = New-Object System.Drawing.Size(480,80)
        $label1.Font = New-Object System.Drawing.Font("Lucida Console",12,[System.Drawing.FontStyle]::Regular)
        $label1.Text = 'This program will send a certain amount of PINGS (1 per second) to a Domain/IP Address, then will present the results as a Line Graph.  This information could help in tracing intermittent download/upload speed fluctuations'
        $form.Controls.Add($label1)

        $label2 = New-Object System.Windows.Forms.Label
        $label2.Location = New-Object System.Drawing.Point(10,150)
        $label2.Size = New-Object System.Drawing.Size(480,40)
        $label2.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
        $label2.Text = 'How Many Pings would you like to send (1 per second, so 100 pings takes 100 seconds)'
        $form.Controls.Add($label2)

        $label3 = New-Object System.Windows.Forms.Label
        $label3.Location = New-Object System.Drawing.Point(10,250)
        $label3.Size = New-Object System.Drawing.Size(480,20)
        $label3.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
        $label3.Text = 'What Domain/site to ping (domain name or IP):'
        $form.Controls.Add($label3)

        $textBox1 = New-Object System.Windows.Forms.TextBox
        $textBox1.Location = New-Object System.Drawing.Point(10,190)
        $textBox1.Size = New-Object System.Drawing.Size(50,20)
        $form.Controls.Add($textBox1)

        $textBox2 = New-Object System.Windows.Forms.TextBox
        $textBox2.Location = New-Object System.Drawing.Point(10,280)
        $textBox2.Size = New-Object System.Drawing.Size(200,20)
        $form.Controls.Add($textBox2)

        $form.Topmost = $true

        $form.Add_Shown({$textBox1.Select()})
        $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $pingsToSend = [int]$textBox1.Text
            $siteToPing = $textBox2.Text

        }  else {Exit}

        $form.Close()
        
        if ($siteToPing -match '\b(?:\d{1,3}\.){3}\d{1,3}\b') {
        $ipAddressResolved = $siteToPing
    } else {
        $ipAddressResolved = (Resolve-DnsName $siteToPing)[1].IPAddress
    }
  #$siteToPing = "192.168.1.1"
        
        
    #Show the Progress Window
        $progressForm.Show()

    #Loop Test-Connection as many times as entered into form
        $results = @()
        $y=1
            For ($i=$pingsToSend; $i -gt 0; $i--) {
                if ( (Test-NetConnection $ipAddressResolved).PingSucceeded){
                $x = Test-NetConnection $ipAddressResolved | Select ComputerName, @{Name="RoundTrip";expression={$_.PingReplyDetails.RoundtripTime}}
                $x | Add-Member -NotePropertyName PingNumber -NotePropertyValue $y
                $pingResults = $x | Select PingNumber, 'RoundTrip'
                $results += $pingResults
                $y++

                #This updates the Progress Window
                $percentComplete = (($pingsToSend - $i)/$pingsToSend)*100
                $pcInt = [int]$percentComplete
                $pcRounded = [math]::Round($pcInt)
                $progressLabel.Text =  [string]$pcRounded + "% Complete"
                $progressForm.Refresh()

                Sleep 1
                } Else {
                    $progressForm.Close()
                    [System.Windows.MessageBox]::Show('Name Resolution Failed: OK to Exit')
                    break foobar
                    }
            }

    #Close the Progress window
        $progressForm.Close()
        
    #This section reformats the retrieved data to convert to a Chart
    $forChart = @()

    foreach ($x in $results){
        $a = [int]$x.PingNumber
        $b = [int]$x.RoundTrip
        $Object = New-Object System.Object
            $Object | Add-Member -type NoteProperty -name PingNumber -Value $a
            $Object | Add-Member -type NoteProperty -name RoundTrip -Value $b
            
    $forChart += $Object
        } 

    ##############################################################################

    #Creates the Line Chart
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]
    $Series.ChartType = $ChartTypes::Line

    $Chart.Series.Add($Series)
    $Chart.ChartAreas.Add($ChartArea)

    $Chart.Series['Series1'].Points.DataBindXY($forChart.PingNumber, $forChart.RoundTrip)

    $Chart.Width = 1000
    $Chart.Height = 510
    $Chart.Left = 10
    $Chart.Top = 10
    $Chart.BackColor = [System.Drawing.Color]::SlateGray
    $Chart.BorderColor = 'Black'
    $Chart.BorderDashStyle = 'Solid'

    $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
    $ChartTitle.Text = 'pinging results of ' + $siteToPing + ' (' + $ipAddressResolved + ')'
    $Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
    $ChartTitle.Font =$Font
    $Chart.Titles.Add($ChartTitle)


    $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.IsEquallySpacedItems = $True
    $Legend.BorderColor = 'Black'

    $Chart.Legends.Add($Legend)
    $Chart.Series["Series1"].LegendText = "Round Trip Ping in MS"
    $Chart.ChartAreas[0].BackColor = [System.Drawing.Color]::CornflowerBlue
    $Chart.Series[0].Color = [System.Drawing.Color]::DarkRed
    $Chart.Series[0].BorderWidth = 3;



    $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
        [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
    $Form = New-Object Windows.Forms.Form
    $Form.Width = 1030
    $Form.Height = 605
    $Form.controls.add($Chart)
    $Chart.Anchor = $AnchorAll
    
    # add a Export to PNG button
    $SaveButton = New-Object Windows.Forms.Button
    $SaveButton.Size = New-Object System.Drawing.Size(150,23)
    $SaveButton.Text = "Export PNG to Desktop"
    $SaveButton.Top = 540
    $SaveButton.Left = 600
    $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right 

    #save chart.png to Desktop on button click
    $date = Get-Date
    $SaveButton.add_click({$Chart.SaveImage($Env:USERPROFILE + "\Desktop\" + $siteToPing + "-" + $date.ToString("M-dd-yy-hh-mm") + ".png", "PNG"), [System.Windows.MessageBox]::Show('PNG saved as site-date-time on Desktop')})
    $Form.controls.add($SaveButton)

    $Form.controls.add($SaveButton)
    $Form.Add_Shown({$Form.Activate()})
    [void]$Form.ShowDialog()
