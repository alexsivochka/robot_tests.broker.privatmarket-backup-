*** Settings ***
Library  String
Library  Selenium2Library
Library  privatmarket_service.py
Library  Collections
Library  BuiltIn

*** Variables ***
${COMMONWAIT}  12

${tender_data_assetID}  xpath=//div[@tid='assetID']
${tender_data_title}  xpath=//div[@tid='data.title']
${tender_data_description}  xpath=//div[@tid='description']
${tender_data_date}  xpath=//div[@tid='creationDate']
${tender_data_dateModified}  xpath=//div[@tid='modifyDate']
${tender_data_rectificationPeriod.endDate}  xpath=(//div[contains(@class, 'timeleft')])[1]
${tender_data_documents[0].documentType}  xpath=//span[@tid='data.informationDetailstitle']/ancestor::div[1]

${lot_data_lotID}  xpath=//div[@tid='lotID']
${lot_data_date}  xpath=//div[@tid='date']
${lot_data_dateModified}  xpath=//div[@tid='modifyDate']
${lot_data_title}  xpath=//div[@tid='data.title']
${lot_data_rectificationPeriod.endDate}  xpath=//div[@tid='data.rectificationPeriod.endDate']
${lot_data_description}  xpath=//div[@tid='description']

${lot_data_decisions[0].decisionID}  xpath=//div[@tid='decision.0.decisionID']
${lot_data_decisions[0].decisionDate}  xpath=//div[@tid='decision.0.decisionDate']
${lot_data_decisions[1].title}  xpath=//div[@tid='decision.1.title']
${lot_data_decisions[1].decisionDate}  xpath=//div[@tid='decision.1.decisionDate']
${lot_data_decisions[1].decisionID}  xpath=//div[@tid='decision.1.decisionID']

${lot_data_assets}  xpath=//div[@tid='asset']

${lot_data_lotHolder.name}  xpath=//div[@tid='lotHolder.name']
${lot_data_lotHolder.identifier.scheme}  xpath=//div[@tid='lotHolder.identifier.scheme']
${lot_data_lotHolder.identifier.id}  xpath=//div[@tid='lotHolder.identifier.id']

${lot_data_lotCustodian.identifier.scheme}  xpath=//div[@tid='data.assetCustodian.identifier.scheme']
${lot_data_lotCustodian.identifier.id}  xpath=//div[@tid='data.assetCustodian.identifier.id']
${lot_data_lotCustodian.identifier.legalName}  xpath=//div[@tid='data.assetCustodian.identifier.legalName']
${lot_data_lotCustodian.contactPoint.name}  xpath=//div[@tid='data.lotCustodian.contactPoint.name']
${lot_data_lotCustodian.contactPoint.telephone}  xpath=//div[@tid='data.lotCustodian.contactPoint.telephone']
${lot_data_lotCustodian.contactPoint.email}  xpath=//div[@tid='data.lotCustodian.contactPoint.email']

${tender_data_decisions[0].title}  xpath=//div[@tid='decision.title']
${tender_data_decisions[0].decisionDate}  xpath=//div[@tid='decision.date']
${tender_data_decisions[0].decisionID}  xpath=//div[@tid='decision.id']

${tender_data_assetHolder.name}  xpath=//div[@tid='assetHolder.name']
${tender_data_assetHolder.identifier.id}  xpath=//div[@tid='assetHolder.identifier.id']
${tender_data_assetHolder.identifier.scheme}  xpath=//div[@tid='assetHolder.identifier.scheme']

${tender_data_assetCustodian.contactPoint.name}  xpath=//div[@tid='data.assetCustodian.contactPoint.name']
${tender_data_assetCustodian.contactPoint.telephone}  xpath=//div[@tid='data.assetCustodian.contactPoint.telephone']
${tender_data_assetCustodian.contactPoint.email}  xpath=//div[@tid='data.assetCustodian.contactPoint.email']
${tender_data_assetCustodian.identifier.scheme}  xpath=//div[@tid='data.assetCustodian.identifier.scheme']
${tender_data_assetCustodian.identifier.id}  xpath=//div[@tid='data.assetCustodian.identifier.id']
${tender_data_assetCustodian.identifier.legalName}  xpath=//div[@tid='data.assetCustodian.identifier.legalName']

${tender_data.assets.description}  div[@tid="item.description"]
${tender_data.assets.classification.scheme}  span[@tid="item.classification.scheme"]
${tender_data.assets.classification.id}  span[@tid="item.classification.id"]
${tender_data.assets.unit.name}  span[@tid="item.unit.name"]
${tender_data.assets.quantity}  span[@tid="item.quantity"]
${tender_data.assets.registrationDetails.status}  div[@tid="item.registrationDetails.status"]


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
  Go To  ${USERS.users['${username}'].homepage}
  Run Keyword Unless  'Viewer' in '${username}'  Login  ${username}


Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  Run Keyword If  '${role_name}' != 'tender_owner'  Return From Keyword  ${tender_data}
  ${tender_data}=  modify_test_data  ${tender_data}
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


Створити лот
  [Arguments]  ${user_name}  ${tender_data}  ${asset_id}
  ${decisions_date}=  Get From Dictionary  ${tender_data.data.decisions[0]}  decisionDate
  ${decisions_id}=  Get From Dictionary  ${tender_data.data.decisions[0]}  decisionID
  privatmarket.Пошук об’єкта МП по ідентифікатору  ${user_name}  ${asset_id}
  Wait Enable And Click Element  css=button[tid='btn.createInfo']
  ${correctDate}=  Convert Date  ${decisions_date}  result_format=%d/%m/%Y
  ${correctDate}=  Convert To String  ${correctDate}
  Input text  xpath=//input[@tid='decision.date']  ${correctDate}
  Wait Until Element Is Enabled  xpath=//input[@tid='decision.id']  ${COMMONWAIT}
  Input text  xpath=//input[@tid='decision.id']  ${decisions_id}
  Execute Javascript  angular.prozorroaccelerator=240
  Click Element  xpath=//button[@tid='btn.createaInfo']
  Wait For Ajax
  Execute Javascript  document.querySelector("span[tid='lotID']").className = ''
  sleep  2
  ${tender_id}=  Get Element Attribute  xpath=//span[@tid='lotID']@data-id
  [Return]  ${tender_id}


Додати умови проведення аукціону
  [Arguments]  ${username}  ${tender_data}  ${index}  ${tender_id}
  Run Keyword If  '${index}' == '0'
  ...  Заповнити дані про аукціон  ${tender_data}
  ...  ELSE  Заповнити тривалість аукціону  ${tender_data}


Заповнити дані про аукціон
  [Arguments]  ${tender_data}
  ${date}=  Get From Dictionary  ${tender_data.auctionPeriod}  startDate
  ${correctDate}=  Convert Date Format  ${date}
  ${value}=  Convert To String  ${tender_data.value.amount}
  ${guarantee}=  Convert To String  ${tender_data.guarantee.amount}
  ${minimalStep}=  Convert To String  ${tender_data.minimalStep.amount}
  ${registrationFee}=  Convert To String  ${tender_data.registrationFee.amount}
  Wait Enable And Click Element  css=input[tid='valueAddedTaxIncluded']
  Wait Until Element Is Visible  css=input[tid='auction.value']  ${COMMONWAIT}
  Input Text  css=input[tid='auction.value']  ${value}
  Input Text  css=input[tid='auction.guarantee']  ${guarantee}
  Input Text  css=input[tid='auction.minimalStep']  ${minimalStep}
  Input Text  css=input[tid='auction.period']  ${correctDate}
  Input Text  css=input[tid='auction.registrationFee']  ${registrationFee}
  Input Text  css=input[tid='auction.bankAccount.description']  ${tender_data.bankAccount.description}
  Input Text  css=input[tid='auction.bankAccount.bankName']  ${tender_data.bankAccount.bankName}
  Input Text  css=input[tid='auction.bankAccount.accountIdentification.mfo']  ${tender_data.bankAccount.accountIdentification[0].scheme}
  Input Text  css=input[tid='auction.bankAccount.accountIdentification.crf']  ${tender_data.bankAccount.accountIdentification[0].id}


Заповнити тривалість аукціону
  [Arguments]  ${tender_data}
  ${duration}=  Get From Dictionary  ${tender_data}  tenderingDuration
  ${count}=  Set Variable If  '${duration}' == 'P1M'  30
  Input Text  xpath=//input[@tid='auction.tenderingDuration']  ${count}
  Click Element  xpath=//button[@tid='btn.createInfo']
  Wait Until Element Is Visible  ${lot_data_title}  ${COMMONWAIT}


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
  Sleep  1s
  Select From List  xpath=(//select[@tid='registrationDetails.status'])[last()]  string:${item.registrationDetails.status}

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


Оновити сторінку з лотом
  [Arguments]  ${user_name}  ${tender_id}
  privatmarket.Оновити сторінку з об'єктом МП  ${user_name}  ${tender_id}


Пошук об’єкта МП по ідентифікатору
  [Arguments]  ${user_name}  ${tender_id}
  Wait For Auction  ${tender_id}
  Wait For Ajax
  Wait Enable And Click Element  css=div[tid='${tender_id}']
  Wait Until element Is Visible  css=div[tid='data.title']  ${COMMONWAIT}


Пошук лоту по ідентифікатору
  [Arguments]  ${user_name}  ${tender_id}
  privatmarket.Пошук об’єкта МП по ідентифікатору  ${user_name}  ${tender_id}


Отримати інформацію з активу об'єкта МП
  [Arguments]  ${username}  ${tender_id}  ${object_id}  ${field_name}
  ${element}=  Convert To String  assets.${field_name}
  ${element_for_work}=  Set variable  xpath=//div[@ng-repeat='item in data.items' and contains(., '${object_id}')]//${tender_data.${element}}
  Wait For Element With Reload  ${element_for_work}

  Run Keyword And Return If  '${field_name}' == 'quantity'  Отримати число  ${element_for_work}
  Run Keyword And Return If  '${field_name}' == 'registrationDetails.status'  Отримати registrationDetails.status  ${element_for_work}

  Wait Until Element Is Visible  ${element_for_work}  timeout=${COMMONWAIT}
  ${result}=  Отримати текст елемента  ${element_for_work}
  [Return]  ${result}


Отримати інформацію з рішення
  [Arguments]  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'decisions[0].decisionID'  Get Text  ${lot_data_decisions[0].decisionID}
  Run Keyword And Return If  '${field_name}' == 'decisions[1].title'  Get Text  ${lot_data_decisions[1].title}
  Run Keyword And Return If  '${field_name}' == 'decisions[1].decisionID'  Get Text  ${lot_data_decisions[1].decisionID}
  Run Keyword And Return If  'decisionDate' in '${field_name}'  Отримати дату з рішення  ${field_name}


Отримати інформацію з активу лоту
  [Arguments]  ${username}  ${tender_id}  ${object_id}  ${field_name}
  ${result}=  privatmarket.Отримати інформацію з активу об'єкта МП  ${username}  ${tender_id}  ${object_id}  ${field_name}
  [Return]  ${result}


Отримати інформацію із об'єкта МП
  [Arguments]  ${user_name}  ${tender_id}  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'status'  Отримати status об'єкту МП  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'decisions[0].decisionDate'  Отримати дату  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'dateModified'  Отримати дату внесення змін  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'date'  Отримати creationDate   ${field_name}
  Run Keyword And Return If  '${field_name}' == 'rectificationPeriod.endDate'  Отримати rectificationPeriod.endDate  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'documents[0].documentType'  Отримати documents[0].documentType  ${field_name}

  Wait Until Element Is Visible  ${tender_data_${field_name}}
  ${result_full}=  Get Text  ${tender_data_${field_name}}
  ${result}=  Strip String  ${result_full}
  [Return]  ${result}


Отримати інформацію із лоту
  [Arguments]  ${user_name}  ${tender_id}  ${field_name}
  ${status}=  Run Keyword And Return Status  Wait Until Element Is Visible  css=.glyphicon-plus-sign  1s
  Run Keyword If  ${status}  Click Element  css=.glyphicon-plus-sign

  Run Keyword And Return If  '${field_name}' == 'status'  Отримати status лоту  ${field_name}
  Run Keyword And Return If  'procurementMethodType' in '${field_name}'  Отримати тип аукціону  ${field_name}
  Run Keyword And Return If  'status' in '${field_name}' and 'auction' in '${field_name}'  Отримати статус аукціону  ${field_name}
  Run Keyword And Return If  'tenderAttempts' in '${field_name}'  Отримати кількість виставлень лоту  ${field_name}
  Run Keyword And Return If  'value.amount' in '${field_name}'  Отримати початкову вартість аукціону  ${field_name}
  Run Keyword And Return If  'minimalStep.amount' in '${field_name}'  Отримати крок аукціону  ${field_name}
  Run Keyword And Return If  'guarantee.amount' in '${field_name}'  Отримати розмір гарантійного внеску аукціону  ${field_name}
  Run Keyword And Return If  'registrationFee.amount' in '${field_name}'  Отримати розмір реєстраційного внеску аукціону  ${field_name}
  Run Keyword And Return If  'tenderingDuration' in '${field_name}'  Отримати період на подачу пропозицій  ${field_name}
  Run Keyword And Return If  'auctionPeriod.startDate' in '${field_name}'  Отримати дату початку аукціону  ${field_name}
  Run Keyword And Return If  'decisions' in '${field_name}'  Отримати інформацію з рішення  ${field_name}
  Run Keyword And Return If  'date' in '${field_name}'  Отримати lot_dates  ${field_name}
  Run Keyword And Return If  '${field_name}' == 'rectificationPeriod.endDate'  Отримати lot_dates  ${field_name}

  Wait Until Element Is Visible  ${lot_data_${field_name}}
  ${result_full}=  Get Text  ${lot_data_${field_name}}
  ${result}=  Strip String  ${result_full}
  [Return]  ${result}


Отримати тип аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Get Element Attribute  xpath=//div[@tid="auction.${index[0]}.procurementMethod"]@tidvalue
  [Return]  ${result}


Отримати статус аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Get Element Attribute  xpath=//div[@tid="auction.${index[0]}.status"]@tidvalue
  [Return]  ${result}


Отримати кількість виставлень лоту
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Отримати текст елемента  xpath=//div[@tid="auction.${index[0]}.tenderAttempts"]
  ${result}=  Convert To Number  ${result}
  [Return]  ${result}


Отримати початкову вартість аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Отримати текст елемента  xpath=//span[@tid="auction.${index[0]}.value.amount"]
  ${result}=  Remove String  ${result}  ${SPACE}
  ${result}=  Replace String  ${result}  ,  .
  ${result}=  Convert To Number  ${result}
  [Return]  ${result}


Отримати крок аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Отримати текст елемента  xpath=//span[@tid="auction.${index[0]}.minimalStep.amount"]
  ${result}=  Remove String  ${result}  ${SPACE}
  ${result}=  Replace String  ${result}  ,  .
  ${result}=  Convert To Number  ${result}
  [Return]  ${result}


Отримати розмір гарантійного внеску аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Отримати текст елемента  xpath=//span[@tid="auction.${index[0]}.guarantee.amount"]
  ${result}=  Remove String  ${result}  ${SPACE}
  ${result}=  Replace String  ${result}  ,  .
  ${result}=  Convert To Number  ${result}
  [Return]  ${result}


Отримати розмір реєстраційного внеску аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Отримати текст елемента  xpath=//span[@tid="auction.${index[0]}.registrationFee.amount"]
  ${result}=  Remove String  ${result}  ${SPACE}
  ${result}=  Replace String  ${result}  ,  .
  ${result}=  Convert To Number  ${result}
  [Return]  ${result}


Отримати період на подачу пропозицій
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Get Element Attribute  xpath=//div[@tid="auction.${index[0]}.tenderingDuration"]@tidvalue
  [Return]  ${result}


Отримати дату початку аукціону
  [Arguments]  ${field_name}
  ${index}=  Get Regexp Matches  ${field_name}  [(\\d)]  0
  ${result}=  Get Element Attribute  xpath=//div[@tid="auction.${index[0]}.auctionPeriod.startDate"]@tidvalue
  [Return]  ${result}


Внести зміни в об'єкт МП
  [Arguments]  ${user_name}  ${tender_id}  ${field_name}  ${value}
  Reload Page
  Sleep  5s
  Wait Enable And Click Element  xpath=//button[@tid='btn.modifyLot']
  Run Keyword If
    ...  '${field_name}' == 'title'  Внести зміни в поле  css=input[tid='asset.title']  ${value}
    ...  ELSE IF  '${field_name}' == 'description'  Внести зміни в поле  css=textarea[tid="asset.description"]  ${value}
    ...  ELSE IF  '${field_name}'== 'decisions[0].title'  Внести зміни в поле  xpath=(//input[@tid="decision.title"])  ${value}


Внести зміни в лот
  [Arguments]  ${user_name}  ${tender_id}  ${field_name}  ${value}
  Reload Page
  Sleep  5s
  Wait Enable And Click Element  xpath=//button[@tid='btn.modifyLot']
  Завантажити документ про зміни  ${username}  ${tender_id}
  Run Keyword If
    ...  '${field_name}' == 'title'  Внести зміни в поле  css=input[tid='lot.title']  ${value}
    ...  ELSE IF  '${field_name}' == 'description'  Внести зміни в поле  css=textarea[tid="lot.description"]  ${value}


Внести зміни в актив об'єкта МП
  [Arguments]  ${user_name}  ${item_id}  ${tender_id}  ${field_name}  ${value}
  Reload Page
  Sleep  5s
  Wait Enable And Click Element  xpath=//button[@tid='btn.modifyLot']
  ${quantity}=  Run Keyword If  '${field_name}' == 'quantity'  Convert To String  ${value}
  Run Keyword If
    ...  '${field_name}' == 'quantity'  Внести зміни в поле  xpath=(//input[@tid='item.quantity'])  ${quantity}
    ...  ELSE IF  '${field_name}' == 'description'  Внести зміни в поле  css=textarea[tid="asset.description"]  ${value}


Внести зміни в актив лоту
  [Arguments]  ${user_name}  ${item_id}  ${tender_id}  ${field_name}  ${value}
  Reload Page
  Sleep  5s
  Wait Enable And Click Element  xpath=//button[@tid='btn.modifyLot']
  Завантажити документ про зміни  ${username}  ${tender_id}
  ${quantity}=  Run Keyword If  '${field_name}' == 'quantity'  Convert To String  ${value}
  Run Keyword If
    ...  '${field_name}' == 'quantity'  Внести зміни в поле  xpath=(//input[@tid='item.quantity'])  ${quantity}


Внести зміни в умови проведення аукціону
  [Arguments]  ${username}  ${tender_id}  ${field_name}  ${value}  ${auction_index}
  Reload Page
  Sleep  5s
  Wait Enable And Click Element  xpath=//button[@tid='btn.modifyLot']
  Завантажити документ про зміни  ${username}  ${tender_id}
  ${correct_value}=  Run Keyword If
    ...  'amount' in '${field_name}'  Convert To String  ${value}
    ...  ELSE IF  '${field_name}' = 'auctionPeriod.startDate'  Convert Date Format  ${value}
  Run Keyword If
    ...  '${field_name}' == 'value.amount'  Внести зміни в поле  xpath=(//input[@tid='auction.value'])  ${correct_value}
    ...  ELSE IF  '${field_name}' == 'minimalStep.amount'  Внести зміни в поле  xpath=(//input[@tid='auction.minimalStep'])  ${correct_value}
    ...  ELSE IF  '${field_name}' == 'guarantee.amount'  Внести зміни в поле  xpath=(//input[@tid='auction.guarantee'])  ${correct_value}
    ...  ELSE IF  '${field_name}' == 'registrationFee.amount'  Внести зміни в поле  xpath=(//input[@tid='auction.registrationFee'])  ${correct_value}
    ...  ELSE IF  '${field_name}' == 'auctionPeriod.startDate'  Внести зміни в поле  xpath=(//input[@tid='auction.period'])  ${correct_value}


Видалити об'єкт МП
  [Arguments]  ${user_name}  ${tender_id}
  Switch Browser  ${ALIAS_NAME}
  Reload Page
  Wait Until Page Contains  Виключено з переліку  60


Видалити лот
  [Arguments]  ${user_name}  ${tender_id}
  Switch Browser  ${ALIAS_NAME}
  Reload Page
  Wait Until Page Contains  Об’єкт виключено  60


Внести зміни в поле
  [Arguments]  ${elementLocator}  ${input}
  Wait Until Element Is Visible  ${elementLocator}  ${COMMONWAIT}
  Input Text  ${elementLocator}  ${input}
  Run Keyword If
    ...  '${MODE}' == 'assets'  Wait Enable And Click Element  css=button[tid='btn.createasset']
    ...  ELSE IF  '${MODE}' == 'lots'  Wait Enable And Click Element  css=button[tid="btn.createInfo"]


Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  ${doc}=  Set Variable  xpath=//div[@id='fileitem' and contains(., '${doc_id}')]
  ${file_name}=  Get Element Attribute  ${doc}@title
  ${file_url}=  Get Element Attribute  ${doc}@url
  openprocurement_client_helper.download_file_from_url  ${file_url}  ${OUTPUT_DIR}${/}${file_name}
  Sleep  5s
  [Return]  ${file_name}


Отримати status об'єкту МП
  [Arguments]  ${element}
  Reload Page
  Sleep  5s
  ${element_text}=  Get Text  xpath=//span[@tid='data.statusName']/span[1]
  ${text}=  Strip String  ${element_text}
  ${text}=  Replace String  ${text}  ${\n}  ${EMPTY}
  ${result}=  Set Variable If
  ...  '${text}' == 'Чернетка'  draft
  ...  '${text}' == 'Опубліковано. Очікування інформаційного повідомлення'  pending
  ...  '${text}' == 'Публікація інформаційного повідомлення'  verification
  ...  '${text}' == 'Інформаційне повідомлення опубліковано'  active
  ...  '${text}' == 'Аукціон завершено'  complete
  ...  '${text}' == 'Виключено з переліку'  deleted
  ...  ${element}
  [Return]  ${result}


Отримати registrationDetails.status
  [Arguments]  ${element}
  ${text}=  Отримати текст елемента  ${element}
  ${result}=  Set Variable If
  ...  '${text}' == 'невідомо (не застосовується)'  unknown
  ...  '${text}' == 'об’єкт реєструється'  registering
  ...  '${text}' == 'об’єкт зареєстровано'  complete
  ...  ${element}
  [Return]  ${result}


Отримати creationDate
  [Arguments]  ${field_name}
  ${result}=  Get Element Attribute  ${tender_data_${field_name}}@data-date
  [Return]  ${result}


Отримати дату внесення змін
  [Arguments]  ${field_name}
  ${result}=  Get Element Attribute  ${tender_data_${field_name}}@data-date
  [Return]  ${result}


Отримати rectificationPeriod.endDate
  [Arguments]  ${field_name}
  ${result}=  Get Element Attribute  ${tender_data_${field_name}}@data-enddate
  [Return]  ${result}


Отримати lot_dates
  [Arguments]  ${field_name}
  ${result}=  Get Element Attribute  ${lot_data_${field_name}}@tidvalue
  [Return]  ${result}


Отримати documents[0].documentType
  [Arguments]  ${field_name}
  ${result}=  Get Element Attribute  ${tender_data_${field_name}}@data-docType
  [Return]  ${result}


Отримати status лоту
  [Arguments]  ${element}
  Reload Page
  Sleep  5s
  ${element_text}=  Get Text  xpath=//span[@tid='data.statusName']/span[1]
  ${text}=  Strip String  ${element_text}
  ${text}=  Replace String  ${text}  ${\n}  ${EMPTY}
  ${result}=  Set Variable If
  ...  '${text}' == 'Чернетка'  draft
  ...  '${text}' == 'Публікація інформаційного повідомлення'  composing
  ...  '${text}' == 'Перевірка доступності об’єкту'  verification
  ...  '${text}' == 'Опубліковано'  pending
  ...  '${text}' == 'Об’єкт виставлено на продаж'  active.salable
  ...  '${text}' == 'Аукціон'  active.auction
  ...  '${text}' == 'Аукціон завершено. Кваліфікація'  active.contracting
  ...  '${text}' == 'Аукціон завершено'  pending.sold
  ...  '${text}' == 'Аукціон завершено. Об’єкт не продано'  pending.dissolution
  ...  '${text}' == 'Об’єкт продано'  sold
  ...  '${text}' == 'Об’єкт не продано'  dissolved
  ...  '${text}' == 'Об’єкт виключено'  deleted
  ...  ${element}
  [Return]  ${result}


Отримати дату
  [Arguments]  ${field_name}
  Switch Browser  ${ALIAS_NAME}
  ${result_full}=  Get Text  ${tender_data_${field_name}}
  ${result_full}=  Convert Date  ${result_full}  date_format=%d-%m-%Y
  [Return]  ${result_full}


Отримати дату з рішення
  [Arguments]  ${field_name}
  ${result_full}=  Get Text  ${lot_data_${field_name}}
  ${result_full}=  Split String  ${result_full}  -
  ${day_length}=  Get Length  ${result_full[0]}
  ${day}=  Set Variable If  '${day_length}' == '1'  0${result_full[0]}  ${result_full[0]}
  ${month}=  Set Variable  ${result_full[1]}
  ${year}=  Set Variable  ${result_full[2]}
  ${result}=  Set Variable  ${year}-${month}-${day}
  [Return]  ${result}


Завантажити документ про зміни
  [Arguments]  ${username}    ${tender_id}
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Execute Javascript  document.querySelector("input[id='input-doc-info']").className = ''
  Sleep  2s
  Choose File  css=input[id='input-doc-info']  ${file_path}
  Sleep  10s
  Wait Until Element Is Visible  xpath=(//select[@tid="doc.type"])[last()]
  Select From List  xpath=(//select[@tid="doc.type"])[last()]  string:technicalSpecifications
  Sleep  2s


Завантажити ілюстрацію в об'єкт МП
  [Arguments]  ${user_name}  ${tender_id}  ${image_path}
  Wait Enable And Click Element  css=button[tid="btn.modifyLot"]
  Wait Until Element Is Visible  css=button[tid="btn.createasset"]
  Execute Javascript  document.querySelector("input[id='input-doc-asset']").className = ''
  Sleep  2s
  Choose File  css=input[id='input-doc-asset']  ${image_path}
  Sleep  10s
  Wait Until Element Is Visible  css=select[tid="doc.type"]
  Select From List  css=select[tid="doc.type"]  string:illustration
  Sleep  2s
  Wait Enable And Click Element  css=button[tid="btn.createasset"]


Завантажити ілюстрацію в лот
  [Arguments]  ${username}  ${tender_id}  ${image_path}
  Wait Enable And Click Element  css=button[tid="btn.modifyLot"]
  Execute Javascript  document.querySelector("input[id='input-doc-info']").className = ''
  Sleep  2s
  Choose File  css=input[id='input-doc-info']  ${image_path}
  Sleep  10s
  Wait Until Element Is Visible  css=select[tid="doc.type"]
  Select From List  css=select[tid="doc.type"]  string:illustration
  Sleep  2s
  Wait Enable And Click Element  css=button[tid="btn.createInfo"]


Завантажити документ в об'єкт МП з типом
  [Arguments]  ${user_name}  ${tender_id}  ${file_path}  ${doc_type}
  Wait Enable And Click Element  css=button[tid="btn.modifyLot"]
  Wait Until Element Is Visible  css=button[tid="btn.createasset"]
  Execute Javascript  document.querySelector("input[id='input-doc-asset']").className = ''
  Sleep  2s
  Choose File  css=input[id='input-doc-asset']  ${file_path}
  Sleep  10s
  Wait Until Element Is Visible  xpath=(//select[@tid="doc.type"])[last()]
  Select From List  xpath=(//select[@tid="doc.type"])[last()]  string:${doc_type}
  Sleep  2s
  Wait Enable And Click Element  css=button[tid="btn.createasset"]


Завантажити документ в лот з типом
  [Arguments]  ${user_name}  ${tender_id}  ${file_path}  ${doc_type}
  Wait Enable And Click Element  css=button[tid="btn.modifyLot"]
  Execute Javascript  document.querySelector("input[id='input-doc-info']").className = ''
  Sleep  2s
  Choose File  css=input[id='input-doc-info']  ${file_path}
  Sleep  10s
  Wait Until Element Is Visible  xpath=(//select[@tid="doc.type"])[last()]
  Select From List  xpath=(//select[@tid="doc.type"])[last()]  string:${doc_type}
  Sleep  2s
  Wait Enable And Click Element  css=button[tid="btn.createInfo"]


Завантажити документ в умови проведення аукціону
  [Arguments]  ${user_name}  ${tender_id}  ${file_path}  ${doc_type}  ${auction_index}
  privatmarket.Завантажити документ в лот з типом  ${user_name}  ${tender_id}  ${file_path}  ${doc_type}


Завантажити документ для видалення об'єкта МП
  [Arguments]  ${user_name}  ${tender_id}  ${file_path}
  Wait Enable And Click Element  css=button[tid="btn.cancellationLot"]
  Execute Javascript  document.querySelector("input[id='docsCancellation']").className = ''
  Sleep  2s
  Choose File  css=input[id='docsCancellation']  ${file_path}
  Sleep  10s
  Wait Enable And Click Element  css=button[tid='btn.cancellation']


Завантажити документ для видалення лоту
  [Arguments]  ${user_name}  ${tender_id}  ${file_path}
  privatmarket.Завантажити документ для видалення об'єкта МП  ${user_name}  ${tender_id}  ${file_path}


Отримати кількість активів в об'єкті МП
  [Arguments]  ${user_name}  ${tender_id}
  ${count}=  Get Matching Xpath Count  //div[@ng-repeat="item in data.items"]
  [Return]  ${count}


Додати актив до об'єкта МП
  [Arguments]  ${user_name}  ${tender_id}  ${item}
  Wait Enable And Click Element  css=button[tid="btn.modifyLot"]
  Wait Visibility And Click Element  css=button[tid="btn.additem"]
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
  Sleep  1s
  Select From List  xpath=(//select[@tid='registrationDetails.status'])[last()]  string:${item.registrationDetails.status}
  Sleep  1s
  Wait Enable And Click Element  css=button[tid="btn.createasset"]
  Wait For Element With Reload  xpath=//div[text()='${item.description}']


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


Wait Visibility And Click Element
    [Arguments]  ${elementLocator}
    Wait Until Element Is Visible  ${elementLocator}  ${COMMONWAIT}
    Click Element  ${elementLocator}


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


Convert Date Format
  [Arguments]  ${element}
  ${result}=  Split String  ${element}  T
  ${date}=  Set Variable  ${result[0]}
  ${correctDate}=  Convert Date  ${date}  result_format=%d/%m/%Y
  [Return]  ${correctDate}


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