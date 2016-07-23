_ = require 'lodash'

module.exports =
  latexFilter: (str) ->
    # escape special characters
    str = str.replace /([\&\%\$\#\_\{\}\~\^\\])/g, "\\$1"
    # put in pretty opening quotes
    str.replace /"([^"]+")/g, "``$1"

  findInTree: (point, tag) -> _.find(point.tree, 'tag': tag)?.data or ''

  findMainValue: (point, tag) =>
    # This function is for some properties, 'BIRT' for example,
    # that may have their value stored either as the 'data'
    # property or from within a tree. For BIRT, the date is
    # either in point.data OR inside point.tree with a tag of
    # 'DATE'. This lets us grab whichever one fits---it needs
    # to be separate from the findInTree method because we may
    # not want point.data for EVERY answer -- birthplace, for
    # example, will ONLY be in a tree, and never stored in
    # point.data
    point.data or _.find(point.tree, 'tag': tag)?.data or ''

  nameFormat: (str) -> str.replace /\//g, ''