*** Settings ***
Library  String
Library  Selenium2Library
Library  privatmarket_service.py
Library  Collections
Library  BuiltIn

*** Variables ***
${COMMONWAIT}  8

${tender_data_assetID}  xpath=//div[@tid='assetID']
${tender_data_title}  xpath=//div[@tid='data.title']
${tender_data_description}  xpath=//div[@tid='description']

${tender_data_decisions[0].title}  xpath=//div[@tid='decision.title']
${tender_data_decisions[0].decisionDate}  xpath=//div[@tid='decision.date']
${tender_data_decisions[0].decisionID}  xpath=//div[@tid='decision.id']
${tender_data_assetHolder.name}  xpath=//div[@tid='assetHolder.name']
${tender_data_assetHolder.identifier.id}  xpath=//div[@tid='assetHolder.identifier.id']

${tender_data_assetCustodian.contactPoint.name}  xpath=//div[@tid='data.assetCustodian.contactPoint.name']
${tender_data_assetCustodian.contactPoint.telephone}  xpath=//div[@tid='data.assetCustodian.contactPoint.telephone']
${tender_data_assetCustodian.contactPoint.email}  xpath=//div[@tid='data.assetCustodian.contactPoint.email']

${tender_data.assets.description}  div[@tid="item.description"]
${tender_data.assets.classification.scheme}  span[@tid="item.classification.scheme"]
${tender_data.assets.classification.id}  span[@tid="item.classification.id"]
${tender_data.assets.unit.name}  span[@tid="item.unit.name"]
${tender_data.assets.quantity}  span[@tid="item.quantity"]
${tender_data.assets.registrationDetails.status}  span[@tid="item.classification.scheme"]


*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити брaузер, створити обєкт api wrapper, тощо

  ${disabled}  Create List  Chrome PDF Viewer
  ${prefs}  Create Dictionary  download.default_directory=${OUTPUT_DIR}  plugins.plugins_disabled=${disabled}

  ${options}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
  Call Method  ${options}  add_argument  --allow-running-insecure-content
  Call Method  ${options}  add_argument  --disable-web-security
  Call Method  ${options}  add_argument  --nativeEvents\=false
  Call Method  ${options}  add_experimental_option  prefs  ${prefs}

  ${alias}=   Catenate   SEPARATOR=   browser  ${username}
  Set Global Variable  ${ALIAS_NAME}  ${alias}
  Run Keyword  Create WebDriver  Chrome  chrome_options=${options}  alias=${ALIAS_NAME}

  Set Window Size  @{USERS.users['${username}'].size}
  Set Window Position  @{USERS.users['${username}'].position}
#  Set Selenium Implicit Wait  10s
  Go To  ${USERS.users['${username}'].homepage}
  Run Keyword Unless  'Viewer' in '${username}'  Login  ${username}


Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  Run Keyword If  '${role_name}' != 'tender_owner'  Return From Keyword  ${tender_data}
  ${tender_data.data}=  modify_test_data  ${tender_data.data}
  [Return]  ${tender_data}


Створити об'єкт МП
  [Arguments]  ${user_name}  ${tender_data}
  ${decisions}=  Get From Dictionary  ${tender_data.data}  decisions
  ${decisions_number}=  Get Length  ${decisions}
  ${items}=  Get From Dictionary  ${tender_data.data}  items
  ${items_number}=  Get Length  ${items}

  Wait Enable And Click Element  css=#simple-dropdown
  Wait Enable And Click Element  css=a[href='#/add-asset']
  Wait Until Element Is Visible  css=input[tid="asset.title"]  ${COMMONWAIT}

  Input text  css=input[tid="asset.title"]  ${tender_data.data.title}
  Input text  css=input[tid="asset.title_ru"]  ${tender_data.data.title_ru}
  Input text  css=input[tid="asset.title_en"]  ${tender_data.data.title_en}

  Input text  css=textarea[tid="asset.description"]  ${tender_data.data.description}
  Input text  css=textarea[tid="asset.description_ru"]  ${tender_data.data.description_ru}
  Input text  css=textarea[tid="asset.description_en"]  ${tender_data.data.description_en}

  :FOR  ${index}  IN RANGE  ${decisions_number}
  \  ${should_we_click_btn_add_decision}=  Set Variable If  '0' != '${index}'  ${True}  ${False}
  \  Додати рішення  ${decisions[${index}]}  ${should_we_click_btn_add_decision}


  Wait Enable And Click Element  css=a[ng-click="assetHolder = !assetHolder"]
  Wait Until Element Is Enabled  css=input[tid="assetHolder.identifier.id"]  ${COMMONWAIT}
  Input text  css=input[tid="assetHolder.identifier.id"]  ${tender_data.data.assetHolder.identifier.id}
  Input text  css=input[tid="assetHolder.identifier.legalName"]  ${tender_data.data.assetHolder.identifier.legalName}
  Input text  css=input[tid="assetHolder.address.street"]  ${tender_data.data.assetHolder.address.streetAddress}
  Input text  css=input[tid="assetHolder.address.locality"]  ${tender_data.data.assetHolder.address.locality}
  Input text  css=input[tid="assetHolder.address.region"]  ${tender_data.data.assetHolder.address.region}
  Input text  css=input[tid="assetHolder.address.postalCode"]  ${tender_data.data.assetHolder.address.postalCode}
  Input text  css=input[tid="assetHolder.address.country"]  ${tender_data.data.assetHolder.address.countryName}
  Input text  css=input[tid="assetHolder.contacts.name"]  ${tender_data.data.assetHolder.contactPoint.name}
  Input text  css=input[tid="assetHolder.contacts.email"]  ${tender_data.data.assetHolder.contactPoint.email}
  Input text  css=input[tid="assetHolder.contacts.phone"]  ${tender_data.data.assetHolder.contactPoint.telephone}
  Input text  css=input[tid="assetHolder.contacts.fax"]  ${tender_data.data.assetHolder.contactPoint.faxNumber}
  Input text  css=input[tid="assetHolder.contacts.url"]  ${tender_data.data.assetHolder.contactPoint.url}

  :FOR  ${index}  IN RANGE  ${items_number}
  \  ${should_we_click_btn_add_item}=  Set Variable If  '0' != '${index}'  ${True}  ${False}
  \  Додати об'єкт продажу  ${items[${index}]}  ${should_we_click_btn_add_item}

  Click Button  css=button[tid="btn.createasset"]
  Wait For Ajax
  Wait Until Element Is Not Visible  css=div.progress.progress-bar  ${COMMONWAIT}
  Wait Until Element Is Visible  css=div[tid='data.title']  ${COMMONWAIT}
  Wait For Ajax
  Wait Enable And Click Element  css=button[tid="btn.publicateLot"]
  Wait For Ajax
  Wait For Element With Reload  xpath=//div[contains(@tid, 'assetID') and contains(., 'UA-')]
  ${tender_id}=  Get Text  css=div[tid='assetID']
  Go To  ${USERS.users['${username}'].homepage}
  Wait For Ajax
  [Return]  ${tender_id}


Додати рішення
  [Arguments]  ${decision}  ${should_we_click_btn_add_decision}=${False}
  Run Keyword If  ${should_we_click_btn_add_decision}  Wait Visibulity And Click Element  css=button[tid="btn.adddecision"]
  Sleep  1s
  Input text  xpath=(//input[@tid="decision.title"])[last()]  ${decision.title}
  Input text  xpath=(//input[@tid="decision.title_ru"])[last()]  ${decision.title_ru}
  Input text  xpath=(//input[@tid="decision.title_en"])[last()]  ${decision.title_en}

  ${correctDate}=  Convert Date  ${decision.decisionDate}  result_format=%d/%m/%Y
  ${correctDate}=  Convert To String  ${correctDate}

  Input text  xpath=(//input[@tid="decision.date"])[last()]  ${correctDate}
  Input text  xpath=(//input[@tid="decision.id"])[last()]  ${decision.decisionID}


Додати об'єкт продажу
  [Arguments]  ${item}  ${should_we_click_btn_add_item}=${False}
  Run Keyword If  ${should_we_click_btn_add_item}  Wait Visibulity And Click Element  css=button[tid="btn.additem"]
  Sleep  1s
  Input text  xpath=(//textarea[@tid="item.description"])[last()]  ${item.description}
  #classification
  Input text  xpath=(//div[@tid='classification']//input)[last()]  ${item.classification.id}
  Wait Until Element Is Enabled  xpath=(//ul[contains(@class, 'ui-select-choices-content')])[last()]
  Wait Enable And Click Element  xpath=//span[@class='ui-select-choices-row-inner' and contains(., '${item.classification.id}')]
  #quantity
  ${quantity}=  Convert To String  ${item.quantity}
  Input text  xpath=(//input[@tid='item.quantity'])[last()]  ${quantity}
  Select From List  xpath=(//select[@tid='item.unit.name'])[last()]  ${item.unit.name}

  #address
  Select Checkbox  xpath=(//input[@tid='item.address.checkbox'])[last()]
  Input text  xpath=(//input[@tid='item.address.countryName'])[last()]  ${item.address.countryName}
  Input text  xpath=(//input[@tid='item.address.postalCode'])[last()]  ${item.address.postalCode}
  Input text  xpath=(//input[@tid='item.address.region'])[last()]  ${item.address.region}
  Input text  xpath=(//input[@tid='item.address.streetAddress'])[last()]  ${item.address.streetAddress}
  Input text  xpath=(//input[@tid='item.address.locality'])[last()]  ${item.address.locality}


Оновити сторінку з об'єктом МП
  [Arguments]  ${user_name}  ${tender_id}
  Switch Browser  ${ALIAS_NAME}
  ${tenderEdit}=  Run Keyword And Return Status  Wait Until Element Is Visible  css=input[tid='data.title']  5s
  Run Keyword If  '${tenderEdit}' == 'False'  Reload Page
  Sleep  3s


Пошук об’єкта МП по ідентифікатору
  [Arguments]  ${user_name}  ${tender_id}
  Wait For Auction  ${tender_id}
  Wait For Ajax
  Wait Enable And Click Element  css=div[tid='${tender_id}']
  Wait Until element Is Visible  css=div[tid='data.title']  ${COMMONWAIT}


Отримати інформацію з активу об'єкта МП
  [Arguments]  ${username}  ${tender_id}  ${object_id}  ${field_name}
  ${element}=  Convert To String  assets.${field_name}
  ${element_for_work}=  Set variable  xpath=//div[@ng-repeat='item in data.items' and contains(., '${object_id}')]//${tender_data.${element}}
  Wait For Element With Reload  ${element_for_work}

  Run Keyword And Return If  '${field_name}' == 'quantity'  Отримати число  ${element_for_work}

  Wait Until Element Is Visible  ${element_for_work}  timeout=${COMMONWAIT}
  ${result}=  Отримати текст елемента  ${element_for_work}
  [Return]  ${result}


Отримати інформацію із об'єкта МП
  [Arguments]  ${user_name}  ${tender_id}  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'status'  Отримати status об'єкту МП  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'decisions[0].decisionDate'  Отримати дату  ${field_name}

  Wait Until Element Is Visible  ${tender_data_${field_name}}
  ${result_full}=  Get Text  ${tender_data_${field_name}}
  ${result}=  Strip String  ${result_full}
  [Return]  ${result}


Отримати status об'єкту МП
  [Arguments]  ${element}
  Reload Page
  Sleep  5s
  ${element_text}=  Get Text  xpath=//span[@tid='data.statusName']/span[1]
  ${text}=  Strip String  ${element_text}
  ${result}=  Set Variable If
  ...  '${text}' == 'Чернетка'  draft
  ...  '${text}' == 'Опубліковано. Очікування інформаційного повідомлення'  pending
  ...  '${text}' == 'Публікація інформаційного повідомлення'  verification
  ...  '${text}' == 'Інформаційне повідомлення опубліковано'  active
  ...  '${text}' == 'Аукціон завершено'  complete
  ...  '${text}' == 'Виключено з переліку'  deleted
  ...  ${element}
  [Return]  ${result}


Отримати дату
  [Arguments]  ${element_name}
  Switch Browser  ${ALIAS_NAME}
  ${result_full}=  Get Text  ${element_name}
  ${result_full}=  Split String  ${result_full}  '-'
  ${day_length}=  Get Length  ${result_full[0]}
  ${day}=  Set Variable If  '${day_length}' == '1'  0${result_full[0]}  ${result_full[0]}
  ${month}=  Set Variable  ${result_full[1]}
  ${year}=  Set Variable  ${result_full[2]}
  ${result_full}=  Set Variable  ${year}-${month}-${day} ${result_full[2]}
  [Return]  ${result_full}


Login
  [Arguments]  ${username}
  Sleep  15s
  Wait Enable And Click Element  css=a[ui-sref='modal.login']
  Login with email  ${username}
  ${notification_visibility}=  Run Keyword And Return Status  Wait Until Element Is Visible  css=button[ng-click='later()']
  Run Keyword If  '${notification_visibility}' == 'True'  Click Element  css=button[ng-click='later()']
  Wait Until Element Is Not Visible  css=button[ng-click='later()']
  Wait For Ajax
  Wait Until Element Is Visible  css=input[tid='global.search']  ${COMMONWAIT}


Login with P24
  [Arguments]  ${username}
  Wait Enable And Click Element  xpath=//a[contains(@href, 'https://bankid.privatbank.ua')]
  Wait Until Element Is Visible  id=inputLogin  5s
  Input Text  id=inputLogin  +${USERS.users['${username}'].login}
  Input Text  id=inputPassword  ${USERS.users['${username}'].password}
  Click Element  css=.btn.btn-success.custom-btn
  Wait Until Element Is Visible  css=input[id='first-section']  5s
  Input Text  css=input[id='first-section']  12
  Input Text  css=input[id='second-section']  34
  Input Text  css=input[id='third-section']  56
  Sleep  1s
  Click Element  css=.btn.btn-success.custom-btn-confirm.sms
  Sleep  3s
  Wait For Ajax
  Wait Until Element Is Not Visible  css=div#preloader  ${COMMONWAIT}
  Wait Until Element Is Not Visible  css=.btn.btn-success.custom-btn-confirm.sms


Login with email
  [Arguments]  ${username}
  Wait Until Element Is Visible  css=input[id='email']  5s
  Input Text  css=input[id='email']  ${USERS.users['${username}'].login}
  Input Text  css=input[id='password']  ${USERS.users['${username}'].password}
  Click Element  css=button[type='submit']
  Sleep  3s
  Wait For Ajax


Wait For Ajax
  Get Location
  Sleep  4s


Wait Enable And Click Element
  [Arguments]  ${elementLocator}
  Wait Until Element Is Enabled  ${elementLocator}  ${COMMONWAIT}
  Click Element  ${elementLocator}
  Wait For Ajax


Wait For Auction
  [Arguments]  ${tender_id}
  Wait Until Keyword Succeeds  5min  10s  Try Search Auction  ${tender_id}


Try Search Auction
  [Arguments]  ${tender_id}
  Wait For Ajax
  Wait Until element Is Enabled  css=input[tid='global.search']  ${COMMONWAIT}
  ${text_in_search}=  Get Value  css=input[tid='global.search']

  Run Keyword Unless  '${tender_id}' == '${text_in_search}'  Run Keywords  Clear Element Text  css=input[tid='global.search']
  ...  AND  Input Text  css=input[tid='global.search']  ${tender_id}

  Press Key  css=input[tid='global.search']  \\13
  Wait Until Element Is Not Visible  css=div.progress.progress-bar  15s
  Wait Until Element Is Not Visible  css=div[role='dialog']  15s
  Wait Until Element Is Visible  css=div[tid='${tender_id}']  ${COMMONWAIT}
  [Return]  True


Wait For Element With Reload
  [Arguments]  ${locator}  ${time_to_wait}=4
  Wait Until Keyword Succeeds  ${time_to_wait}min  15s  Try Search Element  ${locator}


Try Search Element
  [Arguments]  ${locator}
  Reload Page
  Wait For Ajax
  Wait Until Element Is Visible  ${locator}  7
  Wait Until Element Is Enabled  ${locator}  5
  [Return]  True


Отримати текст елемента
  [Arguments]  ${element_name}
  ${temp_name}=  Remove String  ${element_name}  '
  ${selector}=  Set Variable If
  ...  'css=' in '${temp_name}' or 'xpath=' in '${temp_name}'  ${element_name}
  ...  ${tender_data.${element_name}}

  Wait Until Element Is Visible  ${selector}
  ${result_full}=  Get Text  ${selector}
  ${result}=  Strip String  ${result_full}
  [Return]  ${result}


Отримати число
  [Arguments]  ${element_name}
  ${value}=  Отримати текст елемента  ${element_name}
  ${value}=  Replace String  ${value}  ${SPACE}  ${EMPTY}
  ${value}=  Replace String  ${value}  ,  .
  ${result}=  Convert To Number  ${value}
  [Return]  ${result}