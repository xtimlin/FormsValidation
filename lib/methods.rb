require 'csv'
require 'set'

module Methods
  ###########################################################################################
  # Author: Tim
  # load all configuration data
  ###########################################################################################
  def loadConfigData
    envConfig = "#{$ROOT}/config/envConfig.yml"
    envConfig = YAML::load(File.open(envConfig))
    envConfig
  end

  ###########################################################################################
  # Author: Tim
  # Open Chrome Browser using Selenium Google Chrome Driver
  ###########################################################################################
  def openBrowser
    Selenium::WebDriver::Chrome.driver_path = "#{$ROOT}/webDriver/chromedriver.exe"
    browser = Watir::Browser.new(:chrome, :switches => %w[--start-maximized])
    browser
  end

  ###########################################################################################
  # Author: Tim
  # Checking URL see if it is pointing to local HTML file
  ###########################################################################################
  def checkURL(url)
    url = "#{$ROOT}/html/index.html" if url.match?(/^localURL$/)
    url
  end

  ###########################################################################################
  # Author: Tim
  # Browser Navigate to URL
  ###########################################################################################
  def openURL(browser, url)
    browser.goto(url)
  end

  ###########################################################################################
  # Author: Tim
  # Capture Table data
  ###########################################################################################
  def captureTable(name)
    tableObj = @PageObject[name].to_a
    getTableHelper(tableObj)
  end

  ###########################################################################################
  # Author: Tim
  # Validate Screen Object for both ID and Values
  ###########################################################################################
  def validateResult(tableData)
    tableData = preSetData(tableData)
    reportData = genReport(tableData)
    reportData
  end

  ###########################################################################################
  # Author: Tim
  # Generate Field Level Comparison Report
  ###########################################################################################
  def generatedReport(validateData)
    folder = generatedReportFolder
    path = "#{folder}/output.csv"
    writeDataToReport(path, validateData)
    path
  end

  ###########################################################################################
  # Author: Tim
  # Write Result to Report
  ###########################################################################################
  def writeDataToReport(path, validateData)
    file = File.open(path, 'w')
    validateData.each do |row|
      file.puts row.join(',')
    end
    file.close
  end

  ###########################################################################################
  # Author: Tim
  # Generated Report Out Folder
  ###########################################################################################
  def generatedReportFolder
    currentData, currentTime = DateTime.now.strftime("%Y_%m_%d %H_%M").split(' ')
    path = "#{$ROOT}/output"
    creatFolder(path)
    path += "/#{currentData}"
    creatFolder(path)
    path += "/#{currentTime}"
    creatFolder(path)
    path
  end

  ###########################################################################################
  # Author: Tim
  # Create folder if folder not exist
  ###########################################################################################
  def creatFolder(path)
    Dir.mkdir(path) unless File.exists?(path)
  end

  ###########################################################################################
  # Author: Tim
  # Get All Indices Count from Screen
  ###########################################################################################
  def getIDindices(tableData)
    countSet = []
    (tableData['labels'].keys + tableData['values'].keys).each do |key|
      countSet << key.split('_')[-1]
    end
    countSet.to_set.to_a.sort
  end

  ###########################################################################################
  # Author: Tim
  # Generate Field Level Comparison Report Data
  ###########################################################################################
  def genReport(tableData)
    reportData = [['Count', 'LabelID', 'Label', 'ValueID', 'Value', 'Status', 'Message']]
    accumulateSum = 0
    indices = getIDindices(tableData)
    indices.each do |count|
      labelID = "lbl_val_#{count}"
      valueID = "txt_val_#{count}"
      label = tableData['labels'].delete(labelID)
      value = tableData['values'].delete(valueID)
      reportData = countValidation(reportData, count, labelID, valueID, label, value)
      if value != nil
        reportData, accumulateSum = valueValidation(reportData, accumulateSum, count, labelID, valueID, label, value)
      end
    end
    reportData = getTotalSum(reportData, accumulateSum, tableData)
    reportData
  end

  ###########################################################################################
  # Author: Tim
  # Generate Report Data for Index Count
  ###########################################################################################
  def countValidation(reportData, count, labelID, valueID, label, value)
    if label == nil || value == nil
      status = false
      type = label == nil ? 'Value' : 'Label'
      keyID = label == nil ? labelID : valueID
      message = "Missing #{type} ID #{keyID}"
    else
      status = true
      message = "Both #{labelID} and #{valueID} are exist in webPage"
    end
    data = [count, labelID, label, valueID, value.to_s.gsub(',', ''), status, message]
    reportData << data
    reportData
  end

  ###########################################################################################
  # Author: Tim
  # Validated Screen Value Format and Calculate accumulate Sum
  ###########################################################################################
  def valueValidation(reportData, accumulateSum, count, labelID, valueID, label, value)
    if value.match?(/^\$(\d{1,3}(\,\d{3})*|(\d+))(\.\d{2})?$/)
      status = true
      message = 'Validate Currency Format'
      accumulateSum += value.to_s.gsub('$', '').gsub(',', '').to_f
      if value.to_s.gsub('$', '').gsub(',', '').to_f <= 0
        zeroValue = [count, labelID, label, valueID, value.to_s.gsub(',', ''), false, 'value is less than or equal to zero']
      end
    else
      status = false
      message = 'Invalidate Currency Format'
    end
    data = [count, labelID, label, valueID, value.to_s.gsub(',', ''), status, message]
    reportData << data
    [reportData, accumulateSum]
  end

  ###########################################################################################
  # Author: Tim
  # Total Balance Validation Against Listed Values On The Screen.
  ###########################################################################################
  def getTotalSum(reportData, accumulateSum, tableData)
    totalLabelID = tableData['totalLabel'].keys.first
    totalLabel = tableData['totalLabel'].values.first
    totalValueID = tableData['totalValue'].keys.first
    totalValue = tableData['totalValue'].values.first

    if accumulateSum == totalValue.gsub('$', '').gsub(',', '').to_f
      status = true
      message = 'Total Balance Matches With Values Listed On The Screen'
    else
      status = false
      message = "Total Balance NOT Matches - Actual Accumulated Sum(#{accumulateSum}) VS Total Sum on Screen(#{totalValue.gsub(',', '')})"
    end
    data = ['Sum Value', totalLabelID, totalLabel, totalValueID, totalValue.gsub(',', ''), status, message]
    reportData << data
    reportData
  end

  ###########################################################################################
  # Author: Tim
  # Filter with Necessary Data
  ###########################################################################################
  def preSetData(tableData)
    result = {}
    result['labels'] = regexSearchID(tableData, @envConfig['Labels'])
    result['values'] = regexSearchID(tableData, @envConfig['Values'])
    result['totalLabel'] = regexSearchID(tableData, @envConfig['TotalLabel'])
    result['totalValue'] = regexSearchID(tableData, @envConfig['TotalValue'])
    result
  end

  ###########################################################################################
  # Author: Tim
  # Search ID by Regular Expression
  ###########################################################################################
  def regexSearchID(tableData, regexStr)
    result = {}
    tableData.keys.each do |key|
      if key.scan(Regexp.new("#{regexStr}"))[0] == key
        result[key] = tableData[key]
      end
    end
    result
  end

  ###########################################################################################
  # Author: Tim
  # Capture data by row and storage into hash with webObj.ID => webObj.text for all cell
  ###########################################################################################
  def getTableHelper(tableObj)
    data = {}
    tableObj.each do |row|
      row.to_a.each do |cell|
        data[cell.id] = cell.text
      end
    end
    data
  end

  ###########################################################################################
  # Author: Tim
  # reading CSV data into hash object for each row and return all data in array
  ###########################################################################################
  def readCSV(filePath)
    data = []
    CSV.foreach(filePath, :headers => true) do |row|
      row = row.to_h
      row.each do |k, v|
        v = v.to_s
        row[k] = v
      end
      data << row
    end
    data
  end

end