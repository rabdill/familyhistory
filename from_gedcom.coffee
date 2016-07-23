parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'
{latexFilter, findInTree, findMainValue, nameFormat, prepCites} = require './utility'

processRelations = (person) ->
    console.log person.name
    parents = _.filter processed, 'fams': person.parentFams
    dad = _.find parents, 'sex': 'M'
    mom = _.find parents, 'sex': 'F'
    if dad
      dad.number = person.number * 2
      dad.generation = person.generation + 1
      person.father = dad.name
    else
      person.father = 'unknown'

    if mom
      mom.number = (person.number * 2) + 1
      mom.generation = person.generation + 1
      person.mother = mom.name
    else
      person.mother = 'unknown'

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
      date: 'unknown'
      place: ''
    death:
      date: 'unknown'
      place: ''
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
  processed.push addition

# Traverse tree
root = _.find processed, 'name': 'Richard John Abdill III'
root.number = 1
root.generation = 1
processRelations root

interim = _.filter processed, 'number'
fs.writeFileSync 'interim.json', JSON.stringify _.sortBy(processed, 'number'), null, 2

# WRITE THE LATEX FILE
results = ''

for person in _.sortBy(processed, 'number') when person.number
  results += """
  \\person{#{person.name}}{#{person.generation}-#{person.number}}
  \\begin{description}
      \\item[Birth] #{person.birth?.date}#{if person.birth?.date and person.birth?.place then ', ' else ''}#{person.birth?.place}
      \\item[Death] #{person.death?.date}#{if person.death?.date and person.death?.place then ', ' else ''}#{person.death?.place}
      \\item[Spouse] 
      \\item[Father] #{person.father}
      \\item[Mother] #{person.mother}
      \\item[Residence]\\mbox{}
          \\begin{description}
              \\item[1900] somewhere
          \\end{description}
      \\item[Children]
          \\begin{description}
              \\item[with #{if person.spouse then person.spouse.name else 'spouse'}]\\mbox{}
                  \\begin{itemize}
                      \\item 
                  \\end{itemize}
          \\end{description}
  \\end{description}


  \\paragraph lalala
  """

template = fs.readFileSync('template.tex').toString()
combined = template.replace '*****FAMILY_GOES_HERE*****', results
fs.writeFileSync 'results.tex', combined