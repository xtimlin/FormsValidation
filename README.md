# Forms Validation

## Objectives:
1. Need to verify the right count of values appear on the screen
2. Need to verify the values on the screen are greater than 0
3. Need to verify the total balance is correct based on the values listed on the screen
4. Need to verify the values are formatted as currencies
5. Need to verify the total balance matches the sum of the values
6. Create a mockup of what the results would look like assuming all steps passed


## Queries
1. From the email, Savory said I "can do the exercise from the link I sent you in JavaScript", but as we had a discussion before that is a "fictitious site", please provide me with more information.

1. Duplicate objective 3 and 5.
    1. Need to verify the total balance is correct based on the values listed on the screen.
    2. Need to verify the total balance matches the sum of the values.

2. I need more information about this "fictitious site" structure. Can I assume the data that I need to capture will be displayed on the site once I open the link?  Or will there be a login page or do I need to do something such as clicking on the screen to navigate?

3. I need more information on what the web element type shows in the image, will it be one table that contains all label and text detail or two separate lists?

4. In my past experience, I should not directly use field level web ID to capture data. If data are from the list/table, it should capture data by using the web ID from the list/table. By doing so, it will avoid future maintenance if there is a new field add to the table/list. Please let me know if you have the table/list ID or if you would like to stick with the current form to capture data in the framework?

## Know Deviation:
1. I have created a local dummy HTML file with similar UI provide from PPT since I don't have the access to the environment.
2. Modify and using the table ID in the automation script to capture all label and value data.

## Prerequisite
 1. Environment URL.
 2. WebTable ID.
 3. Microsoft Excel.
 4. Update Gemfile:
   1. open Command Prompt and navigate to *.\FormsValidation.
   2. Execute "**gem install**" command in Command Prompt

## How to Execute
1. change the Environment URL:
    1. Open "**envConfig.yml**" file under *.\FormsValidation\config.
    2. Update Environment URL
    3. save and exist the yaml file
2. Update webTable ID
    1. open "**pageObject.csv**" under config folder
    2. update **Identifier** column with the actual web table ID shows on  the page
    3. save and exit the csv file
3. Execute formValidation.feature file under *.\FormsValidation\features
4. Script will auto open the "**output.csv**" report under *.\FormsValidation\output.
   1. Please filter **status** Column to view mismatch field
   2. Message will display the detail.


## Ruby/Gem Version
1. ruby 2.4.4p296 (2018-03-28 revision 63013) [x64-mingw32]
2. gem 'cucumber', '~> 2.4'
3. gem 'watir', '~> 6.1'
4. gem 'watir-webdriver', '~> 0.9.9'