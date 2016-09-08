*** Settings ***
Library  String
Library  Selenium2Library
Library  DebugLibrary
Library  privatmarket_service.py


*** Variables ***
${COMMONWAIT}	10

${tender_data.title}									css=span[tid='data.title']
${tender_data.description}								css=span[tid='data.description']
${tender_data.procuringEntity.name}						css=span[tid='procuringEntity.name']
${tender_data.value.amount}								css=span[tid='data.value.amount']
${tender_data.value.currency}							css=span[tid='data.value.currency']
${tender_data.value.valueAddedTaxIncluded}				css=span[tid='data.value.valueAddedTaxIncluded']
${tender_data.minimalStep.amount}						css=span[tid='data.minimalStep.amount']
${tender_data.minimalStep.currency}						css=span[tid='data.minimalStep.currency']
${tender_data.minimalStep.valueAddedTaxIncluded}		css=span[tid='data.minimalStep.valueAddedTaxIncluded']

${tender_data.auctionID}								css=p[tid='data.auctionID']
${tender_data.enquiryPeriod.startDate}					css=span[tid='data.enquiryPeriod.startDate']
${tender_data.enquiryPeriod.endDate}					css=span[tid='data.enquiryPeriod.endDate']
${tender_data.tenderPeriod.startDate}					css=span[tid='data.tenderPeriod.startDate']
${tender_data.tenderPeriod.endDate}						css=span[tid='data.tenderPeriod.endDate']

${tender_data.items[0].deliveryDate.endDate}			css=span[tid='item.deliveryDate.endDate']
${tender_data.items[0].deliveryLocation.latitude}		css=span[tid='item.deliveryLocation.latitude']
${tender_data.items[0].deliveryLocation.longitude}		css=span[tid='item.deliveryLocation.longitude']
${tender_data.items[0].deliveryAddress.countryName}		css=span[tid='item.deliveryAddress.countryName']
${tender_data.items[0].deliveryAddress.postalCode}		css=span[tid='item.deliveryAddress.postalCode']
${tender_data.items[0].deliveryAddress.region}			css=span[tid='item.deliveryAddress.region']
${tender_data.items[0].deliveryAddress.locality}		css=span[tid='item.deliveryAddress.locality']
${tender_data.items[0].deliveryAddress.streetAddress}	css=span[tid='item.deliveryAddress.streetAddress']
${tender_data.items[0].classification.scheme}			css=span[tid='item.classification.scheme']
${tender_data.items[0].classification.id}				css=span[tid='item.classification.id']
${tender_data.items[0].classification.description}		css=span[tid='item.classification.description']
${tender_data.items[0].unit.name}						css=span[tid='item.unit.name']
${tender_data.items[0].unit.code}						css=span[tid='item.unit.code']
${tender_data.items[0].quantity}						css=span[tid='item.quantity']
${tender_data.items[0].description}						css=span[tid='item.description']

${tender_data.questions[0].title}						css=span[tid='data.question.title']
${tender_data.questions[0].description}					css=span[tid='data.question.description']
${tender_data.questions[0].date}						css=span[tid='data.quesion.date']
${tender_data.questions[0].answer}						css=span[tid='data.question.answer']


*** Keywords ***
Підготувати дані для оголошення тендера
	[Arguments]  ${username}  ${tender_data}  ${role_name}
	[return]	${tender_data}


Підготувати клієнт для користувача
	[Arguments]  ${username}
	[Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо

	${service_args} =	Create List	--ignore-ssl-errors=true	--ssl-protocol=tlsv1
	${browser} =		Convert To Lowercase	${USERS.users['${username}'].browser}

	${options}= 	Evaluate	sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
	Call Method	${options}		add_argument	--allow-running-insecure-content
	Call Method	${options}		add_argument	--disable-web-security
	Call Method	${options}		add_argument	--start-maximized
	Call Method	${options}		add_argument	--nativeEvents\=false

	Run Keyword If	'phantomjs' in '${browser}'	Run Keywords	Create Webdriver	PhantomJS	${username}	service_args=${service_args}
	...   ELSE	Create WebDriver	Chrome	chrome_options=${options}	alias=${username}

	Set Selenium Implicit Wait						10s
	Go To	${USERS.users['${username}'].homepage}
	Run Keyword Unless	'Viewer' in '${username}'	Login	${username}


Оновити сторінку з тендером
	[Arguments]  @{ARGUMENTS}
	Reload Page
	Sleep	2s

Пошук тендера по ідентифікатору
	[Arguments]  ${user_name}  ${tender_id}
	Wait For Auction						${tender_id}
	Wait Enable And Click Element			css=a[tid='${tender_id}']
	Wait Until element Is Visible			css=span[tid='data.title']		${COMMONWAIT}


Отримати інформацію із тендера
	[Arguments]  ${user_name}  ${element}
	#дождаться получения информации по поданным вопросам/ответам
	Run Keyword If	'${element}' == 'questions[0].title'								Wait For Element With Reload			${tender_data.${element}}
	Run Keyword If	'${element}' == 'questions[0].answer'								Wait For Element With Reload			${tender_data.${element}}

	Run Keyword And Return If	'${element}' == 'status'								Отримати status
	Run Keyword And Return If	'${element}' == 'value.amount'							Отримати число							${element}
	Run Keyword And Return If	'${element}' == 'value.valueAddedTaxIncluded'			Отримати інформацію про включення ПДВ	${element}
	Run Keyword And Return If	'${element}' == 'minimalStep.amount'					Отримати число							${element}
	Run Keyword And Return If	'${element}' == 'minimalStep.valueAddedTaxIncluded'		Отримати інформацію про включення ПДВ	${element}
	Run Keyword And Return If	'${element}' == 'enquiryPeriod.startDate'				Отримати дату та час					${element}
	Run Keyword And Return If	'${element}' == 'enquiryPeriod.endDate'					Отримати дату та час					${element}
	Run Keyword And Return If	'${element}' == 'tenderPeriod.startDate'				Отримати дату та час					${element}
	Run Keyword And Return If	'${element}' == 'tenderPeriod.endDate'					Отримати дату та час					${element}
	Run Keyword And Return If	'${element}' == 'items[0].deliveryDate.endDate'			Отримати дату та час					${element}
	Run Keyword And Return If	'${element}' == 'items[0].deliveryLocation.latitude'	Отримати число							${element}
	Run Keyword And Return If	'${element}' == 'items[0].deliveryLocation.longitude'	Отримати число							${element}
	Run Keyword And Return If	'${element}' == 'items[0].quantity'						Отримати число							${element}

	Wait Until Element Is Visible	${tender_data.${element}}	timeout=${COMMONWAIT}
	${result} =						Отримати текст	${element}
	[return]	${result}


Отримати текст
	[Arguments]  ${element_name}
	${result_full} =				Get Text		${tender_data.${element_name}}
	${result} =						Strip String	${result_full}
	[return]	${result}


Отримати число
	[Arguments]  ${element_name}
	${value}=	Отримати текст		${element_name}
	${result}=	Convert To Number	${value}
	[return]	${result}


Отримати дату та час
	[Arguments]  ${element_name}
	${result_full} =	Отримати текст	${element_name}
	${result_full} =	Replace String			${result_full}	з${SPACE}	${EMPTY}
	${result_full} =	Replace String			${result_full}	до${SPACE}	${EMPTY}
	${result} = 		get_time_with_offset	${result_full}
	[return]	${result}


Отримати інформацію про включення ПДВ
	[Arguments]  ${element_name}
	${value_added_tax_included} =	Отримати текст	${element_name}
	${result} =	Set Variable If	'з ПДВ' in '${value_added_tax_included}'	${True}	${False}
	[return]  ${result}


Отримати status
	privatmarket.Оновити сторінку з тендером	status
	${active_active_period} = 	Run Keyword And Return Status	Wait Until Element Is Visible	css=div.arrow-present	5s

	${locator} = 	Set Variable If	${active_active_period}	css=div.arrow-present	css=div.arrow-future
	${status_line} = 	Get Text				${locator}
	@{list} = 			Split String			${status_line}
	${status} = 		Set Variable If	'Уточнення' == '${list[0]}'	active.enquiries
		...  	'Пропозиції' == '${list[0]}'	active.tendering
		...  	'Аукціон' == '${list[0]}'		active.auction
		...  	'Визначення' == '${list[0]}'	active.qualification
		...  	Anknown: ${status_line}
	[return]  ${status}


Задати питання
	[Arguments]  ${user_name}  ${tender_id}  ${question_data}
	Wait Until Element Is Visible			css=input[ng-model='newQuestion.title']	${COMMONWAIT}
	Input Text								css=input[ng-model='newQuestion.title']	${question_data.data.title}
	Input Text								css=textarea[ng-model='newQuestion.text']	${question_data.data.description}
	Click Button							css=button[tid='sendQuestion']
	Sleep									5s
	Wait Until Element Is Not Visible		css=div.progress.progress-bar	${COMMONWAIT}
	Wait For Element With Reload			css=span[tid='data.quesion.date']


Подати цінову пропозицію
	[Arguments]  ${user_name}  ${tender_id}  ${bid}
	#дождаться появления поля ввода ссуммы только в случае выполнения позитивного теста
	Run Keyword Unless					'Неможливість подати цінову' in '${TEST NAME}'	Wait For Element With Reload	css=input[ng-model='newbid.amount']	5
	Input Text							css=input[ng-model='newbid.amount']		${bid.data.value.amount}
	Click Button						css=button[ng-click='createBid(newbid)']
	Wait Until Element Is Visible		css=div.progress.progress-bar			${COMMONWAIT}
	Wait For Ajax
	Wait Until Element Is Not Visible	css=div.progress.progress-bar			${COMMONWAIT}


Скасувати цінову пропозицію
	[Arguments]  ${user_name}  ${tender_id}  ${bid}
	Wait Until Element Is Visible		css=button[ng-click='deleteBid(bid)']	${COMMONWAIT}
	Click Button						css=button[ng-click='deleteBid(bid)']
	Wait Until Element Is Visible		css=div.progress.progress-bar				${COMMONWAIT}
	Wait For Ajax
	Wait Until Element Is Not Visible	css=div.progress.progress-bar			${COMMONWAIT}
	Wait Until Element Is Not Visible	css=button[ng-click='deleteBid(bid)']	${COMMONWAIT}


Змінити цінову пропозицію
	[Arguments]  ${user_name}  ${tender_id}  ${name}  ${value}
	Wait Until Element Is Visible		css=label[ng-click='showModifyBid()']	${COMMONWAIT}
	Click Element						css=label[ng-click='showModifyBid()']
	Clear Element Text					css=input[tid='bid.value.newAmount']
	Input Text							css=input[tid='bid.value.newAmount']		${value}
	Fail								Is not ready yet
	Click Button						css=button[ng-click='createBid(newbid)']
	Wait Until Element Is Visible		css=div.progress.progress-bar			${COMMONWAIT}
	Wait For Ajax
	Wait Until Element Is Not Visible	css=div.progress.progress-bar		${COMMONWAIT}


Завантажити документ в ставку
	[Arguments]  ${user_name}  ${filepath}  ${tender_id}
	Fail	Is not ready yet
	Choose File								css=input#addProposalDocs					${filepath}
	sleep									5s
	Wait Until Element Does Not Contain		css=div.file-item			Файл не выбран
	Click Button							css=button[ng-click='createBid(newbid)']
	Wait Until Element Is Visible			css=div.progress.progress-bar				${COMMONWAIT}
	Wait For Ajax
	Wait Until Element Is Not Visible		css=div.progress.progress-bar				${COMMONWAIT}


Змінити документ в ставці
	[Arguments]  ${user_name}  ${filepath}  ${bidid}  ${docid}
	Fail	Is not ready yet
	Choose File								css=input#modifyDocs	${filepath}
	sleep									5s


Отримати посилання на аукціон для учасника
	[Arguments]  ${user_name}  ${tender_id}
	Wait For Element With Reload			xpath=//div[@ng-if='data.auctionUrl']/a[contains(@href, 'https://auction-sandbox.ea.openprocurement.org')]	5
	${url} = 	Get Element Attribute		xpath=//div[@ng-if='data.auctionUrl']/a[contains(@href, 'https://auction-sandbox.ea.openprocurement.org')]@href
	[return]  ${url}


Отримати посилання на аукціон для глядача
	[Arguments]  ${user_name}  ${tender_id}
	${url} = 	privatmarket.Отримати посилання на аукціон для учасника	${user_name}	${tender_id}
	[return]  ${url}


#Custom Keywords
Login
	[Arguments]  ${username}
	Wait Until Element Is Not Visible	css=div.progress.progress-bar			${COMMONWAIT}
	Sleep				5s
	Wait Until Element Is enabled		css=a[ng-show='bankIdUrl']	${COMMONWAIT}
	Click Element						css=a[ng-show='bankIdUrl']
	Wait Until Element Is Visible		css=div[id='privatBank']				5s
	Click Element						css=div[id='privatBank']
	Wait Until Element Is Visible		css=input[id='loginLikePhone']			5s
	Input Text							css=input[id='loginLikePhone']			+${USERS.users['${username}'].login}
	Input Text							css=input[id='passwordLikePassword']	${USERS.users['${username}'].password}
	Click Element						css=div[id='signInButton']
	Wait Until Element Is Visible		css=input[id='first-section']	5s
	Input Text							css=input[id='first-section']	12
	Input Text							css=input[id='second-section']	34
	Input Text							css=input[id='third-section']	56
	Click Element						css=a[id='confirmButton']
	Sleep								3s
	Wait Until Element Is Not Visible	css=div.progress.progress-bar			${COMMONWAIT}
	Wait Until Element Is Not visible	css=a[id='confirmButton']
	Wait Until Element Is Visible		css=input#businessSearch


Wait For Ajax
	Get Location
	Sleep			3s


Wait Until Element Not Stale
	[Arguments]  ${locator}  ${time}
	sleep 			2s
	${time} = 	Convert To Integer	${time}
	${left_time} =	Evaluate  ${time}-2
	${element_state} =	Check If Element Stale	${locator}
	run keyword if  ${element_state} and ${left_time} > 0	Wait Until Element Not Stale	${locator}	${left_time}


Check If Element Stale
	[Arguments]  ${locator}
	${element} =	Get Webelement	${locator}
	${element_state} =	is_element_not_stale	${element}
	[return]  ${element_state}


Wait Enable And Click Element
	[Arguments]  ${elementLocator}
	Wait Until Element Is enabled	${elementLocator}	${COMMONWAIT}
	Click Element					${elementLocator}
	Wait For Ajax


Wait Visibulity And Click Element
	[Arguments]  ${elementLocator}
	Wait Until Element Is Visible	${elementLocator}	${COMMONWAIT}
	Click Element					${elementLocator}
	Wait For Ajax


Wait For Element Value
	[Arguments]	${locator}
	Wait For Ajax
	${cssLocator} =	Get Substring	${locator}	4
	Wait For Condition				return window.$($("${cssLocator}")).val()!='' && window.$($("${cssLocator}")).val()!='None'	${COMMONWAIT}
	${value}=	get value			${locator}


Get Locator And Type
	[Arguments]	${full_locator}
	${temp_locator} = 	Replace String	${full_locator}	'	${EMPTY}
	${locator} = 	Run Keyword If	'css' in '${temp_locator}'	Get Substring	${full_locator}	4
		...   ELSE IF	'xpath' in '${temp_locator}'	Get Substring	${full_locator}	6
		...   ELSE		${full_locator}

	${type} =	Set Variable If	'css' in '${temp_locator}'	css
		...  	'xpath' in '${temp_locator}'	xpath
		...  	None
	[return]  ${locator}  ${type}


Wait For Auction
	[Arguments]	${tender_id}
	Wait Until Keyword Succeeds	5min	10s	Try Search Auction	${tender_id}


Try Search Auction
	[Arguments]	${tender_id}
	Wait For Ajax
	Wait Until element Is Enabled			css=input#businessSearch		${COMMONWAIT}

	#заполним поле поиска
	${text_in_search} =					Get Value	css=input#businessSearch
	Run Keyword Unless	'${tender_id}' == '${text_in_search}'	Run Keywords	Clear Element Text	css=input#businessSearch
	...   AND   Input Text	css=input#businessSearch	${tender_id}

	#выполним поиск
	Press Key	css=input#businessSearch	\\13
	Wait Until Element Is Not Visible		css=div.progress.progress-bar	${COMMONWAIT}
	Wait Until Element Is Not Visible		css=div[role='dialog']	${COMMONWAIT}
	Wait Until Element Not Stale			css=a[tid='${tender_id}']	${COMMONWAIT}
	Wait Until Element Is Visible			css=a[tid='${tender_id}']	${COMMONWAIT}
	[return]	True


Try Search Element
	[Arguments]	${locator}
	Reload Page
	Wait For Ajax
	Wait Until Element Is Visible	${locator}	3
	Wait Until Element Is Enabled	${locator}	3
	[return]	True


Wait For Element With Reload
	[Arguments]  ${locator}  ${time_to_wait}=2
	Wait Until Keyword Succeeds			${time_to_wait}min	3s	Try Search Element	${locator}


