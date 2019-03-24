Feature: Form Validation

Scenario: User open Browser
    Given Initializing Configuration
    When Open Browser
    Then Goto URL
    Then Initializing PageObject
#    "Main_table" data is the config from pageObject.csv under config folder #{Screen}_#{Description}
    Then Capture Table Data "Main_table"
    When Close browser in "2" Seconds
    Then Validate Table Result
    Then Generated Report
    Then Open Report