
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null


##############################################################
#                      LOAD FUNCTION                         #
##############################################################
                      
# Load MainWindow
$XamlMainWindow=(New-Object System.Xml.XmlDocument)
$XamlMainWindow.Load("Main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)


##############################################################
#                CONTROL INITIALIZATION                      #
##############################################################

$Source    = $Form.FindName("Source")
$WrapPanel = $Form.FindName("WrapPanel")

$Source.AllowDrop = $True

##############################################################
#                FUNCTIONS                                   #
##############################################################


Function NewUserControl(){
    Param(
        [String]$Path
    )

    $name = $Path.Substring($Path.LastIndexOf("\") + 1)

    If((Get-Item $Path) -is [System.IO.DirectoryInfo])
    {
        # Should be a folder then
        $UserControl = NewStackPanelControl -imageType "folder" -elemName $name
    }
    Else
    {
        # It's a file if not a folder :D 
        $UserControl = NewStackPanelControl -imageType "file" -elemName $name
    }

    return $UserControl

}


Function NewStackPanelControl(){

    Param(
        [String]$imageType,
        [String]$elemName
    )

    $Stackpanel = [System.Windows.Controls.StackPanel]::new()
    $Stackpanel.Orientation = "Vertical"
    $Stackpanel.Margin  = "5,5,5,5"
    $Stackpanel.Width   = "60"
    $Stackpanel.Height  = "60"
    $Stackpanel.Background = "#F1F3F4"

    $Image = [System.Windows.Controls.Image]::new()
    $Image.Margin = "0,5,0,2" 
    $Image.Width  ="30" 
    $Image.Height ="30" 
    $Image.Stretch="Fill"  
    If($imageType -eq "folder"){
        $Image.Source = ".\images\folder.png"
    }
    Else{
        $Image.Source = ".\images\file.png"
    }
	
    $TextBlock = [System.Windows.Controls.TextBlock]::new()
    $TextBlock.Text= $elemName 
    $TextBlock.Foreground="#6DA1EC" 
    $TextBlock.Margin="0,2,0,2" 
    $TextBlock.TextWrapping="Wrap"
    $TextBlock.HorizontalAlignment="Center"

    $Stackpanel.Children.Add($Image) | out-Null
    $Stackpanel.Children.Add($TextBlock) | out-Null

    return $Stackpanel

}


##############################################################
#                MANAGE EVENT ON PANEL                       #
##############################################################

$Source.Add_PreviewDragOver({
    [System.Object]$script:sender = $args[0]
    [System.Windows.DragEventArgs]$e = $args[1]

    $e.Effects = [System.Windows.DragDropEffects]::Move
    $e.Handled = $true
})


$Source.Add_Drop({

    [System.Object]$script:sender = $args[0]
    [System.Windows.DragEventArgs]$e = $args[1]

    If($e.Data.GetDataPresent([System.Windows.DataFormats]::FileDrop)){

        $Script:Files =  $e.Data.GetData([System.Windows.DataFormats]::FileDrop)
        #Write-Host $Files.Count

        Foreach($file in $Files){

            $userControl = NewUserControl -Path $file
            $WrapPanel.Children.Add($userControl) | Out-Null

        }

    }

    

})


$Form.ShowDialog() | Out-Null

