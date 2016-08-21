from __future__ import unicode_literals, division, absolute_import
from builtins import *  # pylint: disable=unused-import, redefined-builtin

import logging
import re

from flexget import plugin
from flexget.event import event
from flexget.utils.cached_input import cached
from flexget.entry import Entry
from flexget.utils.soup import get_soup

log = logging.getLogger('myanimelist')


class myanimelist(object):
    """"Creates an entry for each movie or series in your MAL Plan to Watch and/or Watching lists."""

    schema = {
        'properties': {
            'user_id': {
                'type': 'string'
            },
            'list': {
                'type': 'string',
                'enum': ['watching', 'plantowatch', 'both'],
                                'default': 'both'
            }
        }
    }



    @cached('myanimelist', persist='2 hours')
    def on_task_input(self, task, config):

      def get_anime(task, url):
        log.verbose("Requesting %s" % url)
        page = task.requests.get(url)
        if page.status_code != 200:
          raise plugin.PluginError("Unable to get MAL list. Either the list is private or does not exist")
        soup = get_soup(page.text)

        as_ = soup.find_all("a", class_="animetitle")
        entries = []
        for a in as_:
          entry = Entry()

          entry["title"] = a.find("span").text
          entry["myanimelist_name"] = entry["title"]
          entry["url"] = "http://myanimelist.net" + a["href"]
          entries.append(entry)

        return entries


      # Create entries by parsing MAL wishlist page html using beautifulsoup
      url = 'http://myanimelist.net/animelist/%s' % config['user_id']

      entries = []
      if config['list'] == ['watching'] or config['list'] == 'both':
        entries = entries + get_anime(task, url + "?status=1")
      if config['list'] == ['plantowatch'] or config['list'] == 'both':
        entries = entries + get_anime(task, url + "?status=6")

      return entries


@event('plugin.register')
def register_plugin():
    plugin.register(myanimelist, 'myanimelist', api_ver=2, groups=['list'])


