require 'watir'
require 'selenium-webdriver'
require 'csv'
require 'yaml'

$ROOT = "#{Dir.pwd}"
require "#{$ROOT}/lib/methods.rb"
require "#{$ROOT}/lib/pageObject.rb"
include Methods

Given(/^Initializing Configuration/) do
  puts "Initializing Configuration"
  @envConfig, @PageObjectConfig = loadConfigData
end

When(/^Open Browser/) do
  puts "Open Browser"
  @browser = openBrowser
end

Then(/^Initializing PageObject/) do
  puts "Initializing PageObject"
  @PageObject = PageObject.new.loadObject(@browser)
end

When(/^Goto URL/) do
  url = checkURL(@envConfig['Environment'])
  puts "Goto #{url}"
  openURL(@browser, url)
end

Then(/Capture Table Data "([^"]*)"$/) do |arg|
  puts "Capture Table for #{arg}"
  @TableData = captureTable(arg)
end


Then(/Validate Table Result/) do
  @ValidateData = validateResult(@TableData)
end

Then(/Generated Report/) do
  @reportPath = generatedReport(@ValidateData)
end

When(/^Close browser in "([^"]*)" Seconds/) do |arg|
  puts "Browser will be close in #{arg} seconds"
  sleep arg.to_i
  @browser.close
end

Then(/Open Report/) do
  puts "Open Validation Report"
  system("start /wait excel #{@reportPath}")
end
