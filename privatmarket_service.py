# coding=utf-8

from datetime import datetime
from pytz import timezone
import urllib


def modify_test_data(tender_data):
    tender_data['data']['assetCustodian']['identifier']['legalName'] = u'Тестовый Тестовый'
    tender_data['data']['assetCustodian']['identifier']['id'] = u'32855961'
    if 'contactPoint' in tender_data['data']['assetCustodian']:
        tender_data['data']['assetCustodian']['contactPoint']['telephone'] = u'+380123456789'
        tender_data['data']['assetCustodian']['contactPoint']['email'] = u'tadud@p33.org'
        tender_data['data']['assetCustodian']['contactPoint']['name'] = u'Тестовый Тестовый'
    return tender_data


def get_current_year():
    now = datetime.now()
    return now.year
