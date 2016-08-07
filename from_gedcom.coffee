parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'
{latexFilter, findInTree, findMainValue, nameFormat, prepCites} = require './utility'

processRelations = (person) ->
  console.log person.name

  # spouse
  personFam = _.filter processed, 'fams': person.fams
  person.spouse.name = prepCites _.find(personFam, (p) -> p.name isnt person.name)?.name

  # parents:
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

  # child (in the direct line)
  kidNumber = if person.number % 2 is 0 then person.number / 2 else (person.number - 1) / 2
  if kid = _.find processed, {'number': kidNumber}
    primary = prepCites kid.name
    primary.direct_ancestor = true  # flag this kid as the one that gets a number
    person.children.push primary


  # other children
  for kid in _.filter processed, {'parentFams': person.fams}
    person.children.push prepCites kid.name unless kid.number


  # work our way up the tree
  processRelations dad if dad
  processRelations mom if mom

# load the GEDCOM file
raw = fs.readFileSync('abdills.ged').toString()
ged = parser.parse raw
processed = []

for person in ged
  addition =
    name: ''
    birth:
      date:
        value: 'unknown'
        citation: []
      place: ''
    death:
      date:
        value: 'unknown'
        citation: []
      place:
        value: ''
        citation: []
    spouse:
      name:
        value: 'unknown'
        citation: []
    children: []

  for point in person.tree
    switch point.tag
      when 'BIRT'
        addition.birth =
          date: prepCites latexFilter findMainValue point, 'DATE'
          place: prepCites latexFilter findInTree point, 'PLAC'
        # don't allow totally blank entries. This happens if there's a BIRT entry
        # in the GEDCOM file but no data in it.
        unless addition.birth.date.value or addition.birth.place.value
          addition.birth =
            date:
              value: 'unknown'
              citation: []
            place:
              value: ''
              citation: []
      when 'DEAT'
        addition.death =
          date: prepCites latexFilter findMainValue point, 'DATE'
          place: prepCites latexFilter findInTree point, 'PLAC'
        unless addition.death.date.value or addition.death.place.value
          addition.death =
            date:
              value: 'unknown'
              citation: []
            place:
              value: ''
              citation: []
      when 'NAME'
        unless addition.name # take the first name entry we find
          addition.name = latexFilter nameFormat point.data
      when 'SEX'
        addition.sex = latexFilter point.data
      when 'FAMC'
        addition.parentFams = latexFilter point.data
      when 'FAMS'
        addition.fams = latexFilter point.data
  processed.push addition if addition.name

# Traverse tree
root = _.find processed, 'name': 'Richard John Abdill III'
root.number = 1
root.generation = 1
processRelations root

interim = _.filter processed, 'number'
fs.writeFileSync 'interim.json', JSON.stringify _.sortBy(processed, 'number'), null, 2
