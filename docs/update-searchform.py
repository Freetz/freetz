#!/usr/bin/env python3

'''
Find all HTML pages with the default Trac search field, and replace them with Google code
'''

import re
import sys


oldform = '\n\s*<form id="search".*?</form>\n'

newform = '''
      <form id="search" action="https://www.google.com/search" method="get" onsubmit="; this.elements.namedItem('q').value = this.elements.namedItem('oq').value + ' site:freetz.github.io'">
        <div>
          <label for="proj-search">Suche:</label>
          <input type="text" id="proj-search" name="oq" size="18" value="" />
          <input type="hidden" name="q" value="" />
          <input type="submit" value="Suche" />
        </div>
      </form>
'''

def replaceSearchForm(name):
    with open(name, encoding='utf-8') as f:
        s = f.read()
    s = re.sub(oldform, newform, s, flags=re.S)
    with open(name, encoding='utf-8', mode='w') as f:
        f.write(s)


for n in sys.argv:
  replaceSearchForm(n)

