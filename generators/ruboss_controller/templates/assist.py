# The MIT License
# 
# Copyright (c) 2008 Dima Berastau
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.

__author__ = 'Dima Berastau'

from google.appengine.ext import db
import datetime

# Some useful module methods
def all(model):
  items = "\n".join(str(item.to_xml()) for item in model.all())
  return '<entities kind="%s" type="array">%s</entities>' % (model.kind(), items)

def update_model_from_params(model, params):
  for k, v in params.items():
    if k.endswith("_id"):
      setattr(model, k.replace("_id", ""), db.Key(v))
    elif hasattr(model, k):
      if isinstance(getattr(model, k), bool):
        if v == "false" or v == "":
          setattr(model, k, False)
        else:
          setattr(model, k, True)
      elif isinstance(getattr(model, k), datetime.datetime):
        if v == "":
          setattr(model, k, datetime.datetime.now())
        else:
          date = datetime.strptime(v, "%Y-%m-%dT%H:%M:%S")
          setattr(model, k, date)
      else:
        setattr(model, k, v)

  model.put()