parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'

raw = fs.readFileSync('abdills.ged').toString()
ged = parser.parse raw
prettyPrint = (str) -> JSON.stringify str, null, 2

fs.writeFileSync 'interim.json', prettyPrint ged

findInTree = (tree, tag) ->
  z = _.find(tree, 'tag': tag)?.data or ''

processed = []

for person in ged
  addition = {}
  for point in person.tree
    switch point.tag
      when 'BIRT'
        addition.birth =
          date: findInTree point.tree, 'DATE'
          place: findInTree point.tree, 'PLAC'
      when 'NAME'
        addition.name = point.data
  processed.push addition


fs.writeFileSync 'final.json', prettyPrint processed