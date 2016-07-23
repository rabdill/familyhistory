parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'

processed = JSON.parse fs.readFileSync('interim.json').toString()
# WRITE THE LATEX FILE
results = ''

for person in processed when person.number
  results += """
  \\person{#{person.name}}{#{person.generation}-#{person.number}}
  \\begin{description}
      \\item[Birth] #{person.birth?.date.value}#{if person.birth?.date.value and person.birth?.place.value then ', ' else ''}#{person.birth?.place.value}
      \\item[Death] #{person.death?.date.value}#{if person.death?.date.value and person.death?.place.value then ', ' else ''}#{person.death?.place.value}
      \\item[Spouse] #{person.spouse.value}
      \\item[Father] #{person.father}
      \\item[Mother] #{person.mother}
      \\item[Residence]\\mbox{}
          \\begin{description}
              \\item[1900] somewhere
          \\end{description}
      \\item[Children]
          \\begin{itemize}
              \\item 
          \\end{itemize}
  \\end{description}


  \\paragraph lalala



  """

template = fs.readFileSync('template.tex').toString()
combined = template.replace '*****FAMILY_GOES_HERE*****', results
fs.writeFileSync 'results.tex', combined