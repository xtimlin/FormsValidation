class PageObject
  include Methods

  ###########################################################################################
  # Author: Tim
  # Initialize Page Screen Object Configuration
  ###########################################################################################
  def initialize
    csvFile = "#{$ROOT}/config/pageObject.csv"
    @csvData = readCSV(csvFile)
    @PageObject = {}
  end

  ###########################################################################################
  # Author: Tim
  # Generate Watir Screen Object Based on CSV file Configuration
  ###########################################################################################
  def loadObject(browser)
    pageObject = "#{$ROOT}/config/pageObject.csv"
    pageObjectConfig = readCSV(pageObject)
    pageObjectConfig.each do |obj|
      key = obj['Screen'] + '_' + obj['Description']
      webElementType = obj['WebElementType']
      identifyBy = obj['IdentifyBy']
      identifier = obj['Identifier']

      @PageObject[key] = eval("browser.#{webElementType}(#{identifyBy}:'#{identifier}')")
    end
    @PageObject
  end


end