# coding=utf-8

from datetime import datetime
from pytz import timezone


def modify_test_data(initial_data):
    initial_data['assetCustodian']['identifier']['legalName'] = u'Тестовый Тестовый'
    initial_data['assetCustodian']['identifier']['id'] = u'32855961'
    if 'contactPoint' in initial_data['assetCustodian']:
        initial_data['assetCustodian']['contactPoint']['telephone'] = u'+380123456789'
        initial_data['assetCustodian']['contactPoint']['email'] = u'tadud@p33.org'
        initial_data['assetCustodian']['contactPoint']['name'] = u'Тестовый Тестовый'
    return initial_data


def get_current_year():
    now = datetime.now()
    return now.year


def get_month_number(month_name):
    monthes = [u"січня", u"лютого", u"березня", u"квітня", u"травня", u"червня",
               u"липня", u"серпня", u"вересня", u"жовтня", u"листопада", u"грудня",
               u"January", u"February", u"March", u"April", u"May", u"June",
               u"July", u"August", u"September", u"October", u"November", u"December"]
    return monthes.index(month_name) % 12 + 1


def get_time_with_offset(date):
    date_obj = datetime.strptime(date, "%d-%m-%Y %H:%M")
    time_zone = timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime('%Y-%m-%d %H:%M:%S.%f%z')