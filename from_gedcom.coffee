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

  for point in person.tree
    switch point.tag
      when 'BIRT'
        addition.birth =
          date: prepCites latexFilter findMainValue point, 'DATE'
          place: prepCites latexFilter findInTree point, 'PLAC'
      when 'DEAT'
        addition.death =
          date: prepCites latexFilter findMainValue point, 'DATE'
          place: prepCites latexFilter findInTree point, 'PLAC'
      when 'NAME'
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
