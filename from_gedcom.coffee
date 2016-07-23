parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'

raw = fs.readFileSync('abdills.ged').toString()
ged = parser.parse raw
prettyPrint = (str) -> JSON.stringify str, null, 2

#fs.writeFileSync 'interim.json', prettyPrint ged

findInTree = (point, tag) -> _.find(point.tree, 'tag': tag)?.data or ''

findMainValue = (point, tag) ->
  # This function is for some properties, 'BIRT' for example,
  # that may have their value stored either as the 'data'
  # property or from within a tree. For BIRT, the date is
  # either in point.data OR inside point.tree with a tag of
  # 'DATE'. This lets us grab whichever one fits---it needs
  # to be separate from the findInTree method because we may
  # not want point.data for EVERY answer -- birthplace, for
  # example, will ONLY be in a tree, and never stored in
  # point.data
  point.data or findInTree point, tag


processParents = (person) ->
  console.log person.name
  parents = _.filter processed, 'fams': person.parentFams
  dad = _.find parents, 'sex': 'M'
  mom = _.find parents, 'sex': 'F'
  if dad
    dad.number = person.number * 2
    dad.generation = person.generation + 1
    person.father = dad.name
  if mom
    mom.number = (person.number * 2) + 1
    mom.generation = person.generation + 1
    person.mother = mom.name

  processParents dad if dad
  processParents mom if mom

processed = []

for person in ged
  addition = {}
  for point in person.tree
    switch point.tag
      when 'BIRT'
        addition.birth =
          date: findMainValue point, 'DATE'
          place: findInTree point, 'PLAC'
      when 'DEAT'
        addition.birth =
          date: findMainValue point, 'DATE'
          place: findInTree point, 'PLAC'
      when 'NAME'
        addition.name = point.data
      when 'SEX'
        addition.sex = point.data
      when 'FAMC'
        addition.parentFams = point.data
      when 'FAMS'
        addition.fams = point.data
  processed.push addition

# Traverse tree
cur = _.find processed, 'name': 'Richard John /Abdill/ III'
cur.number = 1
cur.generation = 1
processParents cur

fs.writeFileSync 'final.json', prettyPrint processed